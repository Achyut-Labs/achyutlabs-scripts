# ENTRY POINT
# Directory to Watch for Log files, Search Pattern you looking and Name of the Store/System are input Arguments
Param(
    [Parameter(Mandatory=$True)]
    [String] $dir,
    [Parameter(Mandatory=$True)]
    [String] $searchText,
    [Parameter(Mandatory=$True)]
    [String] $StoreName
)

function SendEmail($attachmentpath, $StoreName)
{
    $DST = Get-Date
    $Message = new-object Net.Mail.MailMessage
    $smtp = new-object Net.Mail.SmtpClient("smtp.gmail.com", 587)
    $smtp.Credentials = New-Object System.Net.NetworkCredential("developer@gmail.com", "XXXXXXXX");
    $smtp.EnableSsl = $true
    $smtp.Timeout = 400000
    $Message.From = "PrathamPOS@achyutlabs.com"
    $Message.Subject = "POS Error at $StoreName on $DST"
    $Message.Body = "

    Please check attached Log file and Take Action, there are Errors in it

    "
    $Message.To.Add("info@achyutlabs.com.au")
    $Message.To.Add("kahan.ladani@achyutlabs.com")
    $Message.Attachments.Add("$attachmentpath")
    $smtp.Send($Message)
}

try {
	if ($dir -eq "" ) { $dir = read-host "Enter path to directory tree" }

    # if($file.CreationTime.Date -eq [datetime]::Today){
    #    Write-Output $file
    # }
	$files = Get-ChildItem -path $dir -recurse | Where-Object {$_.CreationTime.Date -eq [datetime]::Today} | Select-Object FullName
    foreach ($file in $files) {
        $attachmentpath = $file.FullName
        if($file = Get-Item $file.FullName -ErrorAction 0) {
            $result = Select-String -Path $file -Pattern $searchText -SimpleMatch
            if(![string]::IsNullOrEmpty($result)){
                SendEmail $attachmentpath $StoreName
            }
        }
    }
	exit 0 # success
} catch {
	"⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	exit 1
}
