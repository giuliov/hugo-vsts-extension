$env:INPUT_SOURCE = '.\test\SITE'
$env:INPUT_DESTINATION = '..\PUBLISH'
$env:INPUT_BASEURL = $null
$env:INPUT_BUILDDRAFTS = 'false'
$env:INPUT_BUILDEXPIRED = 'false'
$env:INPUT_BUILDFUTURE = 'false'
$env:INPUT_ADDITIONALARGS = $null

$env:TASK_TEST_TRACE=1
$env:Agent_ToolsDirectory='C:\src\github.com\giuliov\hugo-azdo-extension\hugo-task\test\TOOLS'
$env:Agent_TempDirectory='C:\src\github.com\giuliov\hugo-azdo-extension\hugo-task\test\TEMP'
$env:Agent_Version='2.115.0'
node ..\dist\src\HugoTask.js