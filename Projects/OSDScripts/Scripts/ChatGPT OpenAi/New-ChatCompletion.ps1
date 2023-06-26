<#
This script will let you have a conversation with ChatGPT.
It shows how to keep a history of all previous messages and feed them into the REST API in order to have an ongoing conversation.
#>

# Login to https://platform.openai.com/account/api-keys and generate an API key
$ApiKey = '<your API key>'

# Set the API endpoint
$ApiEndpoint = "https://api.openai.com/v1/chat/completions"

<#
System message.
You can use this to give the AI instructions on what to do, how to act or how to respond to future prompts.
Default value for ChatGPT = "You are a helpful assistant."
#>
$AiSystemMessage = "You are a helpful assistant"

# we use this list to store the system message and will add any user prompts and ai responses as the conversation evolves.
[System.Collections.Generic.List[Hashtable]]$MessageHistory = @()

# Clears the message history and fills it with the system message (and allows us to reset the history and start a new conversation)
Function Initialize-MessageHistory ($message){
    $script:MessageHistory.Clear()
    $script:MessageHistory.Add(@{"role" = "system"; "content" = $message}) | Out-Null
}

# Function to send a message to ChatGPT. (We need to pass the entire message history in each request since we're using a RESTful API)
function Invoke-ChatGPT ($MessageHistory) {
    # Set the request headers
    $headers = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $ApiKey"
    }   

    # Set the request body
    $requestBody = @{
        "model" = "gpt-3.5-turbo"
        "messages" = $MessageHistory
        "max_tokens" = 1000 # Max amount of tokens the AI will respond with
        "temperature" = 0.7 # Lower is more coherent and conservative, higher is more creative and diverse.
    }

    # Send the request
    $response = Invoke-RestMethod -Method POST -Uri $ApiEndpoint -Headers $headers -Body (ConvertTo-Json $requestBody)

    # Return the message content
    return $response.choices[0].message.content
}

# Show startup text
Clear-Host
Write-Host "######################`n# ChatGPT Powershell #`n######################`n`nEnter your prompt to continue. (type 'exit' to quit or 'reset' to start a new chat)" -ForegroundColor Yellow

# Add system message to MessageHistory
Initialize-MessageHistory $AiSystemMessage

# Main loop
while ($true) {
    # Capture user input
    $userMessage = Read-Host "`nYou"

    # Check if user wants to exit or reset
    if ($userMessage -eq "exit") {
        break
    }
    if ($userMessage -eq "reset") {
        # Reset the message history so we can start with a clean slate
        Initialize-MessageHistory $AiSystemMessage

        Write-Host "Messages reset." -ForegroundColor Yellow
        continue
    }

    # Add new user prompt to list of messages
    $MessageHistory.Add(@{"role"="user"; "content"=$userMessage})

    # Query ChatGPT
    $aiResponse = Invoke-ChatGPT $MessageHistory

    # Show response
    Write-Host "AI: $aiResponse" -ForegroundColor Yellow

    # Add ChatGPT response to list of messages
    $MessageHistory.Add(@{"role"="assistant"; "content"=$aiResponse})
}