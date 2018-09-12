-----------------------------------------------
-- BME280 control libraly for FlashAir W-04
-- 2018/09/11 rev.0.04 I2C control including
-----------------------------------------------
local BME280 = {
	SADR = 0x76;
	TRIM = {};
}

--[Low layer functions]--

--BME280 write data
function BME280:write( ... )
	local res = fa.i2c{ mode="start", address=self.SADR, direction="write" }
	local res = fa.i2c{ mode="write", data=string.char(...) }
	local res = fa.i2c{ mode="stop" }
	return res
end

-- BME280 read table after write adr
function BME280:wreadt( adr, len )
	local res = fa.i2c{ mode="start", address=self.SADR, direction="write" };
	local res = fa.i2c{ mode="write", data=adr };
	local res = fa.i2c{ mode="restart", address=sadr, direction="read" };
	local res, str = fa.i2c{ mode="read", bytes=len, type="string" };
	local res = fa.i2c{ mode="stop" };

	return res, {str:byte(1, #str)}
end

function BME280:calibration_T( adc_T )
	local var1 = (adc_T/16384.0 - self.TRIM.T1/1024.0)
	local var2 =  var1		* self.TRIM.T2
	local var3 = (var1/8)^2 * self.TRIM.T3
	local t_fine = var2 + var3
	self.TRIM.t_fine = t_fine
	local temp = t_fine / 5120.0
	if ( temp<-45 ) then temp=-45 end
	if ( temp> 85 ) then temp=85  end

	return temp
end

function BME280:calibration_P( adc_P )
	local var1 = (self.TRIM.t_fine / 2.0) - 64000.0
	local var2 = var1^2 * self.TRIM.P6 / 32768.0
	local var2 = var2 + var1 * self.TRIM.P5 * 2.0
	local var2 = (var2 / 4.0) + self.TRIM.P4 * 65536.0
	local var3 = self.TRIM.P3 * var1^2 / 524288.0
	local var1 = (var3 + self.TRIM.P2 * var1) / 524288.0
	local var1 = (1.0 + var1 / 32768.0) * self.TRIM.P1

	if (var1 == 0) then
		pres = 30000.0
	else
		pres = (1048576.0 - adc_P - (var2 / 4096.0)) * 6250.0 / var1
		var1 = self.TRIM.P9 * pres^2 / 2147483648.0
		var2 = pres * self.TRIM.P8 / 32768.0
		pres = pres + (var1 + var2 + self.TRIM.P7) /16.0
		pres = pres / 100.0

		if ( pres< 300.0 ) then pres= 300.0 end
		if ( pres>1100.0 ) then pres=1100.0 end
	end

	return pres
end

function BME280:calibration_H( adc_H )
	var1 = self.TRIM.t_fine - 76800.0
	var2 = self.TRIM.H4 * 64.0 - self.TRIM.H5 / 16384.0
	var3 = adc_H - var2
	var4 = self.TRIM.H2 / 65536.0
	var5 = 1.0 + (self.TRIM.H3 / 67108864.0) * var1
	var6 = 1.0 + (self.TRIM.H6 / 67108864.0) * var1 * var5
	var6 = var3 * var4 * (var5 * var6)
	humi = var6 * (1.0 - self.TRIM.H1 * var6 / 524288.0)
	if ( humi<	0.0 ) then humi=  0.0 end
	if ( humi>100.0 ) then humi=100.0 end

	return humi
end

--[For user functions]--

--BME280 setup
function BME280:setup(sadr) -- I2C only
	self.SADR = sadr

	local osrs_t = 4	-- Temperature oversampling x 8
	local osrs_p = 4	-- Pressure oversampling x 8
	local osrs_h = 4	-- Humidity oversampling x 8
	local mode	 = 3	-- Normal mode
	local t_sb	 = 0	-- Tstandby 125ms
	local filter = 0	-- Filter coef=4
	local spi3w_en = 0	-- 3-wire SPI Disable

	local ctrl_meas = (osrs_t * 2^5) + (osrs_p * 2^2) + mode
	local config	= (t_sb   * 2^5) + (filter * 2^2) + spi3w_en
	local ctrl_hum	= osrs_h

	local res = self:write( 0xF2, ctrl_hum,
							0xF4, ctrl_meas,
							0xF5, config
						)
	local res = self:readTrim()

	return res
end

function BME280:readTrim()
	local res, da = self:wreadt( 0x88, 24 )
	local res, db = self:wreadt( 0xA1, 1  )
	local res, dc = self:wreadt( 0xE1, 7  )
	local function u2s(x,n)
		if (x>=2^(n-1)) then x = x-2^n end
		return x
	end

	self.TRIM = {
		T1 =	 (da[2]  * 2^8) + da[1] 	 ;
		T2 = u2s((da[4]  * 2^8) + da[3],  16);
		T3 = u2s((da[6]  * 2^8) + da[5],  16);
		P1 =	 (da[8]  * 2^8) + da[7] 	 ;
		P2 = u2s((da[10] * 2^8) + da[9],  16);
		P3 = u2s((da[12] * 2^8) + da[11], 16);
		P4 = u2s((da[14] * 2^8) + da[13], 16);
		P5 = u2s((da[16] * 2^8) + da[15], 16);
		P6 = u2s((da[18] * 2^8) + da[17], 16);
		P7 = u2s((da[20] * 2^8) + da[19], 16);
		P8 = u2s((da[22] * 2^8) + da[21], 16);
		P9 = u2s((da[24] * 2^8) + da[23], 16);
		H1 =	  db[1];
		H2 = u2s((dc[2]  * 2^8) + dc[1], 16);
		H3 =	  dc[3];
		H4 = u2s((dc[4]  * 2^4) + (dc[5] % 2^4), 16);
		H5 = u2s((dc[6]  * 2^4) + ((dc[5] - dc[5] % 2^4) / 2^4), 16);
		H6 = u2s( dc[7], 8);
		t_fine = 0
	}

	return res
end

function BME280:readData( pres_sea )
	local res, d   = self:wreadt( 0xF7, 8 )
	local pres_raw = (d[1] * 2^12) + (d[2] * 2^4) + (d[3] / 2^4)
	local temp_raw = (d[4] * 2^12) + (d[5] * 2^4) + (d[6] / 2^4)
	local humi_raw = (d[7] * 2^8 ) + d[8]
	local temp	   = self:calibration_T( temp_raw )
	local pres	   = self:calibration_P( pres_raw )
	local humi	   = self:calibration_H( humi_raw )
	local alti	   = 0.0

	if( pres_sea ) then
		local kt   = temp + 273.15
		local p1   = 1013.25
		local dpow = 1.0 / 5.256
		alti = ((p1/pres)^dpow - (p1/pres_sea)^dpow) * kt / 0.0065
	end

	return	res, temp, humi, pres, alti
end

return BME280