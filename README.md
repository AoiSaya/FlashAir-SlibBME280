Under construction.

# FlashAir-SlibBME280

Lua library for BME280 environmental sensor for FlashAir.

## Tested equipment

Tested on this GY-BME280 module with BME280 and FlashAir W-04 v4.00.03.

## FlashAir to BME280 module connections

GY-BME280 has 10korm pull-up register for SCL, SDA, CSB.  
And it has 10korm pull-down register for SD0.  
So, register is not necessary.

GY-BME280 module | FlashAir(Pin#) | Power
--- | --- | ---
SD0 |CLK (5) |
SCL |CMD (2) |
SDA |DAT0(7) |
--- |DAT1(8) |
--- |DAT2(9) |
--- |DAT3(1) |
CSB |---     |
VCC |VCC (4) |3.3V   
GND |VSS(3,6)|GND    

## Install

SlibBME280.lua -- Copy to somewhere in Lua's search path.

## Parameters settings

*Please see the BME280 datasheet for details.*

**Controls the sensor mode of the device**

mode | Mode
--- | ---
0| Sleep mode
1<br>2| Forced mode
3| Normal mode

**Controls inactive duration tstandby in normal mode**

t_sb| tstandby [ms]
--- | ---
0| 0.5
1| 62.5
2| 125
3| 250
4| 500
5| 1000
6| 10
7| 20

**Controls the time constant of the IIR filter**

filter| Filter coefficient
--- | ---
0| Filter off
1| 2
2| 4
3| 8
4<br>others| 16

**Controls oversampling of temperature data.**

osrs_t| Temperature oversampling
--- | ---
0| Skipped
1| oversampling x1
2| oversampling x2
3| oversampling x4
4| oversampling x8
5<br>others| oversampling x16

**Controls oversampling of pressure data**

osrs_p| Pressure oversampling
--- | ---
0| Skipped
1| oversampling x1
2| oversampling x2
3| oversampling x4
4| oversampling x8
5<br>others| oversampling x16

**Controls oversampling of humidity data**

osrs_h| Humidity oversampling
--- | ---
0| Skipped
1| oversampling x1
2| oversampling x2
3| oversampling x4
4| oversampling x8
5<br>others| oversampling x16

## Usage

command | description
--- | ---
res = BME280:setup(<br>sadr, frq, mode, t_sb, filter, osrs_t, osrs_p, osrs_h) |**Setup BME280**<br>**res:** Same as return value of fa.i2c().<br><br>**sadr:** I2C slave address (7bit)<br>**frq:** I2C clock frequency. (45 or 100 or 189 or 400)<br>**mode:** Controls the sensor mode of the device.<br>**t_sb:** Controls inactive duration tstandby in normal mode.<br>**filter:** Controls the time constant of the IIR filter.<br>**osrs_t:** Controls oversampling of temperature data.<br>**osrs_p:** Controls oversampling of pressure data.<br>**osrs_h:** Controls oversampling of humidity data.
res, temp, humi, pres, alti, thi =<br> BME280:readData( pres_sea )  |**Read environmental value**<br>**res:** Same as return value of fa.i2c()<br>**temp:** temperature [DegC] (-45..85)<br>**humi:** humidity [%rH] (0..100)<br>**pres:** pressure [hPa] (300..1100)<br>**alti:** altitude [m]<br>**thi:** temperature-humidity index [%] (0..100)<br><br>**pres_sea:** sea-level pressure[hPa] or nil for 1013.25hPa.

## Licence

[MIT](https://github.com/AoiSaya/FlashAir-libBMP/blob/master/LICENSE)

## Author

[GitHub/AoiSaya](https://github.com/AoiSaya)  
[Twitter ID @La_zlo](https://twitter.com/La_zlo)
