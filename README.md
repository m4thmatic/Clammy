# Clammy
FFXI addon for AshitaXI v4 that displays basic clamming information. Bucket size & weight, countdown timer, and contents.

![](https://private-user-images.githubusercontent.com/14827266/483887124-d3ecca24-e92a-4062-abc9-d0e5403b32db.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTY1NjYzNjcsIm5iZiI6MTc1NjU2NjA2NywicGF0aCI6Ii8xNDgyNzI2Ni80ODM4ODcxMjQtZDNlY2NhMjQtZTkyYS00MDYyLWFiYzktZDBlNTQwM2IzMmRiLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA4MzAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwODMwVDE1MDEwN1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTg5NzA4N2EzZjU3N2Y5NGZjZTJiZmJlOThhMzE0MDEzZDg4OWZhNmNiOWQyN2E0MzVmNDc5MGUyNmE1NzRjZmQmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.cmbO7OoCDFJ9lI2kyIdXzQOM2PPKl2T_lO3Lbdk9JFg)


![](https://private-user-images.githubusercontent.com/14827266/483887150-0a3e3602-dc3e-45ba-b08a-aa126d359e88.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTY1NjYzNjcsIm5iZiI6MTc1NjU2NjA2NywicGF0aCI6Ii8xNDgyNzI2Ni80ODM4ODcxNTAtMGEzZTM2MDItZGMzZS00NWJhLWIwOGEtYWExMjZkMzU5ZTg4LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA4MzAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwODMwVDE1MDEwN1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWE3NDIyMWE3NjRkMWNhOWYzYzM2MjI2OTk0NGFiOTVjNTExNGViYzU0Yjg1ZGY3MTU4MTc4YjQ0Mzc1ZjEwYWUmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.AFr75OUnJx4ysD_Dhed0ges_FXHumKIDQPqEl3JaznQ).
![](https://private-user-images.githubusercontent.com/14827266/483887187-00f2161b-c8a1-469d-9294-930df5379f12.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTY1NjYzNjcsIm5iZiI6MTc1NjU2NjA2NywicGF0aCI6Ii8xNDgyNzI2Ni80ODM4ODcxODctMDBmMjE2MWItYzhhMS00NjlkLTkyOTQtOTMwZGY1Mzc5ZjEyLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA4MzAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwODMwVDE1MDEwN1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWU5NGUyNGFjM2E5ZjE2YzAwZTQyMThmOTI1MDk3ZmE3NzgxYTA0YjEwYmYxODRhYzJhNjlhZWUyNjc2Y2FhN2MmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.Nncmr1jh_xZAfF0zuO0UqvoNP10oqbyRfzewK5069Ts)

### Cleaning up old config
If you are updating this from the previous version of Clammy, please make sure to delete your old config file at:

`%gameinstalldirectory%\Game\config\addons\Clammy\%charactername%_######\settings.lua`

## Commands:
### Options
 `/clammy` *Opens a config menu for general configs*
 `/clammy showvalue [true/false/...]` *Turn display of estimated value on/off*  
 `/clammy showitems [true/false/...]` *Turn display of individual items on/off*  
 `/clammy log [true/false/...]` *Turns on/off results logging - stores file in /addons/Clammy/logs*
 `/clammy tone [true/false/...]` *Turns on/off playing a tone when clamming point is ready to dig*  
 `/clammy logbrokenbucketitems [true/false/...]` *Turns on/off logging if the bucket breaks*
 `/clammy showsessioninfo [true/false/...]` *Turns on/off showing gil/hr, buckets purchased, and total gil earned*
 `/clammy usebucketvalueforweightcolor [true/false/...]` *turns on/off current weight value turning red at certain gil amounts*
 `/clammy setweightvalues [highvalue/midvalue/lowvalue] #####` *Specify a value for when bucket color should turn red*
 `/clammy resetsession` *Resets the current clamming time, buckets purchased, items in bucket, gil/hr, and total gil earned*

### Debug
 `/clammy reset` *Manually clear bucket information*
 `/clammy weight` *Manually adjust bucket weight*
