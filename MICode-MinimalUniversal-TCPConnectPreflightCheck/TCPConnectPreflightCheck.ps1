

# Why and How Blog Post: https://cloudywindows.io/post/mission-impossible-code-part-2-extreme-multilingual-iac-via-standard-code-for-preflight-tcp-connect-testing-a-list-of-endpoints-in-both-bash-and-powershell/
# Windows and Linux Versions: https://github.com/DarwinJS/DevOpsAutomationCode/tree/master/MICode-MinimalUniversal-TCPConnectPreflightCheck

#Design Heuristic:
# 1. This approach should work with all versions of powershell - including those backed by NetCore 2.x
# 2. Receives a single, formatted string (rather than an array or hash or other data type) to:
#  * make it easy to pass a list from any orchestration system regardless of data types it supports
#  * make it easy to pass through as many layers of enclosing automation as necessary without having 
#      to escape or translate sophisticated data types
#  * enables the arguments for the Windows and Linux version to 
#      be exactly the same - in case you are passing into something that accomodates both platforms

# Consider implementing the Minimal, Universal Logging code with the below: https://github.com/DarwinJS/DevOpsAutomationCode/tree/master/MICode-MinimalUniversal-Logging

$UrlPortPairList="outlook.com=80 google.com=80 test.com=442"
$FailureCount=0 ; $ConnectTimeoutMS = '3000'
foreach ($UrlPortPair in $UrlPortPairList.split(' '))
{
  $array=$UrlPortPair.split('='); $url=$array[0]; $port=$array[1]
  write-host "TCP Test of $url on $port"
  $ErrorActionPreference = 'SilentlyContinue'
  $conntest = (new-object net.sockets.tcpclient).BeginConnect($url,$port,$null,$null)
  $conntestwait = $conntest.AsyncWaitHandle.WaitOne($ConnectTimeoutMS,$False)
  if (!$conntestwait)
  { write-host "  Connection to $url on port $port failed"
    $conntest.close()
    $FailureCount++
  }
  else
  { write-host "  Connection to $url on port $port succeeded" }
}
If ($FailureCount -gt 0)
{ write-host "$FailureCount tcp connect tests failed."
  Exit $FailureCount
}
