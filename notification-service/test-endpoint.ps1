# Test script for notification service endpoint

$uri = "http://localhost:8086/notifications/send"
$headers = @{
    "Content-Type" = "application/json"
}
$body = @{
    userEmail = "test@example.com"
    subject = "Test Notification"
    message = "This is a test notification message"
    type = "EMAIL"
} | ConvertTo-Json

try {
    Write-Host "Sending test notification to $uri..."
    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body
    Write-Host "Response: $response"
    Write-Host "Test successful!"
} catch {
    Write-Host "Error: $_"
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)"
    Write-Host "Response: $($_.Exception.Response)"
    Write-Host "Test failed!"
}