$source3 = 'https://1drv.ms/u/s!AqoKz5JfFXu4c6BiBsDipdjPI4s?e=XCLawD'
$installPath = "c:\users\public\downloads\AbsoluteAgent7.20.0.1-50014551.zip"
$webClient = new-object system.net.webclient
$webClient.downloadfile($source3, $installerpath)