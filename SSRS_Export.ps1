$destination_path = "C:\users\me\Desktop";
$reportserver = "SSRS_server_name_or_site";

$url = "http://$($reportserver)/Reportserver/reportservice2010.asmx?WSDL";
$ssrs = New-WebServiceProxy -uri $url -UseDefaultCredential -Namespace "ReportingWebService";


$contents = $ssrs.ListChildren("/", $true); #list children at $ssrs_path with recursive = $true

$contents | ForEach-Object{

    $name = $_.name;
    $path = $_.path;

    switch($_.TypeName){
        "Folder" {
            #Write-Host ("dir: " + $name + ", path: " + $path);
            
            $path = $destination_path + $path.replace('/','\')
            if(!(Test-Path -Path $path )){New-Item -ItemType directory -Path $path}
        }
        "DataSource" {
            #Write-Host ("ds: " + $name + ", path: " + $path);
            #i'm not saving data sources currently
        }
        "Report" {
            #Write-Host ("rdl: " + $name + ", path: " + $path);
            
            $def = $ssrs.GetItemDefinition($path);
            $fname = [system.io.path]::getfilenamewithoutextension($path);
            $stream = [system.io.file]::OpenWrite(($destination_path + ($path.replace('/','\')) + ".rdl"));
            $stream.write($def, 0, $def.length);
            $stream.close();
        }
    }
}

