# Studentkortet.se API
## Endpoint
https://www.studentkortet.se/api/app/cards?memberId=<hashed member id>

## QR code data
The member id can be extracted using the QR-code in the STUK-app.

Example data from QR-code:
```json
{
    "pnr": "<personnummer>",
    "fn": "Fredrik",
    "ln": "Engstrand",
    "id": "<redacted>",
    "o2": "USMOS",
    "o2id": 3377,
    "o3": "Uppsala teknolog- och naturvetarkår",
    "o3id": 3384,
    "o4": "",
    "o4id": "",
    "valid": "2021-09-15",
    "dt": "2021-03-19 10:11:23",
    "check": "93140c6742aebeb0cf028d302cc1238d"
}
```

## Example API response
### Success
```json
{
    "success": true,
    "errorMessage": "",
    "cards": [{
        "front":"https:\/\/www.studentkortet.se\/api\/v2\/cardImages\/index.php?hashedCardNumber=<hashed member id>&md5=d4c7c4b05cc02c76f7b693df21984307&index=0&member_membership=3198938&side=front",
        "back": "https:\/\/www.studentkortet.se\/api\/v2\/cardImages\/index.php?hashedCardNumber=<hashed member id>&md5=d4c7c4b05cc02c76f7b693df21984307&index=0&member_membership=3198938&side=back",
        "qr": "https:\/\/www.studentkortet.se\/api\/v2\/cardImages\/index.php?hashedCardNumber=<hashed member id>&md5=d4c7c4b05cc02c76f7b693df21984307&index=0&member_membership=3198938&side=qr"
    }],
    "md5": "edce795878725bdac9d1f9b1b4d16bd5"
}
```

### Error
```json
{
    "success": false,
    "errorMessage": "Invalid memberId",
    "cards": []
}
```
