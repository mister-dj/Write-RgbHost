function Write-RgbHost {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromRemainingArguments = $true)]
        [string[]]$InputObject,
        [ValidateSet("Wave","Strobe")]
        $Pattern = "Wave",
        [Parameter(mandatory=$false)]
        [int]$Seconds = 0,
        [Parameter(mandatory=$false)]
        [int]$Frequency = 5 #in Hertz
    )
    
    [int[]]$global:ColorSpectrum = 0,9,11,1,3,8,2,5,4,6,7,10,13,12,15,14

    switch($Pattern){
        Strobe{
            Write-Host -ForegroundColor Yellow "This pattern not implemented yet"
        }

        Wave{
            Wave -InputObject $InputObject -Seconds $Seconds -Frequency $Frequency -RandomStartColor
        }

        default{

        }
    }
}

Function Strobe {
#ToDo: add this function
}

Function Wave ([string]$InputObject,[int]$Seconds,[int]$Frequency,[switch]$RandomStartColor,[switch]$NoClearAfter) {
    <#
    Loops through each letter in the input string
    Each letter loops through the color spectrum
    Once it loops through the entire string, it repeats with an offset for the displayed color, such that A -> B becomes B -> C
    #>

    #Setting once here before the loop, is used for loop timing when writing to console
    $SleepTime = 1 / $Frequency

    if($RandomStartColor){
        #Randomly pick a starting color by offsetting the color spectrum
        $Offset = Get-Random -Minimum 0 -Maximum 15
    }
    Else{
        $Offset = 0
    }
    
    #Logic for running continuously
    $KeepLooping = $true
    if($Seconds -ne 0){
        $Loop = $false
    }
    else{
        $Loop = $true
        $Seconds = 5
    }

    while ($KeepLooping){
        For($t=1; $t -lt ($Seconds * $Frequency);$t++){
            #loop back around after going through all characters in the string
            if ($Offset -eq $global:ColorSpectrum.Length){$Offset=0} 

            $Length = $InputObject.Length
            $i = 0
            For($j = 0; $j -lt $Length; $j++) {
                #loop back around after going through all colors
                if ($i -eq $global:ColorSpectrum.Length){$i=0} 
                $FgColor = $global:ColorSpectrum[($i - $Offset)]
        
                Write-Host -NoNewline -ForegroundColor $FgColor $InputObject[$j]
                $i++
            }    

            #Wait and move to the next offset to shift the colors for the "wave"
            Start-Sleep -Seconds $SleepTime

            #Needs to not clear the console on the last iteration of a finite duration if NoClear is true
            if($Loop){
                Clear-Host
            }
            else{
                if($NoClearAfter -and ($t -ne (($Seconds * $Frequency) -1))){
                    Clear-Host
                }
                elseif(!$NoClearAfter){Clear-Host}
            }

            $Offset++        
        }
        $KeepLooping = $Loop
    }
}

#Wave("HELLO WORLD") -Frequency 5 -Seconds 5 -RandomStartColor
Write-RgbHost -InputObject "Hello world :)" -Seconds 5