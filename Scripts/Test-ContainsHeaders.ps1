param (
    $CsvHeaders,
    $Headers
)

foreach($Header in $Headers){
    if(!$CsvHeaders.Contains($Header)){
        return $false;
    }
}

return $true;