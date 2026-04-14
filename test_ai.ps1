$body = @{
    text = "Analyze nutrition for chicken"
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri 'http://localhost:5000/ai' -Method POST -ContentType 'application/json' -Body $body

$response.Content
