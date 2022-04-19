![Logo](https://github.com/Orbis-BlockChain/ORBIS/blob/main/source/ORBIS.jpg)
# Blockchain - ORBIS 
 
ORBIS is a blockchain platform developed in Delphi and is based on TreeChain (MultiChain) technology, providing fast and reliable access to information stored in the system. 
The original ORBIS solution is also a network protocol for transferring blocks to end-nodes, where there is only one node between the "orator" and the "client" - the delegate. This allows instant transfer the blocks and other service data to the end nodes of the system. 
Blockchain also has a service-oriented API that offers developers a quick and easy way to develop any custom services using the ORBIS platform. 
Unlike many other blockchain platforms, ORBIS guarantees the anonymity of users and all of their transactions by ensuring that there is no information about where and where specific formalized data has been sent from. 
ORBIS uses its own ORBFT (Optimization Recognized Byzanine Fault Tolerance) consensus, which incorporates the strengths of the dBFT and PoS algorithms, to provide high-speed transaction validation.

# Download
https://orbis.money/download

# Installing NODE
## OS Windows
**Downloading the installation file.**
- Go to the download page of the new version at the link: http://orbistest.net/win .
Save the installation file on your computer. (Standard path for saving files "C:\User\Downloads ").

**Preparing for installation.**
- Before installing the program, make sure that the computer meets the technical requirements for working with the node. The technical requirements can be found in the "System requirements" section.

**Installing the program.**
- Run the installation file (in some builds of Windows 10, it should be run as an administrator), the default installation path is:"C:\Program Files\ORBIS node", if necessary, specify another folder.

## OS Mac
**Downloading the installation file.**
- Go to the download page of the new version at the link: http://orbistest.net/macos .
Save the installation file on your computer (The standard path for saving files is "Macintosh HD\Users\User\Downloads").

**Preparing for installation.**
- Before installing the program, make sure that the computer meets the technical requirements for working with the node. The technical requirements can be found in the "System requirements" section.

**Installing the program.**
- Run the installation file. When a dialog box appears asking you to confirm the launch of the program, click on the Open button, otherwise proceed to the next step. Specify the disk on which you want to install the program. The disk you selected is indicated by a green arrow. Then click on the Continue button. Before installation, a message will appear asking you to enter the password for the current account. Enter the password and click on the Install Software button.

## OS Linux
**Downloading the installation file.**
- Go to the download page of the new version at the link: http://orbistest.net/Linux .
Save the installation file on your computer (The standard path for saving files is "/home/user/Downloads").

**Preparing for installation.**
- Before installing the program, make sure that the computer meets the technical requirements for working with the node. The technical requirements can be found in the "System requirements" section.

**Installing the program through the terminal**
- Open the terminal, go to the downloaded folder.deb package to register the command:

```sh
sudo dpkg -i ORBISConsole.deb
```

- Wait for the installation to finish, after which the window can be closed. The node can be started by prescribing ORBISConsole.
ORBISConsole is located in the /usr/bin folder.

**Installing the program through the GUI**
- Run the one you downloaded earlier .deb package. The "Ubuntu Software" window will appear in front of you, click the "Install" button. Before installation, a message will appear asking you to enter the password for the superuser account. Wait for the installation to finish, after which the window can be closed. The node is launched through the terminal, open the terminal and register the ORBISCosnole, the node is ready to work.

# System requirements
## **Minimum requirements.**

- **OS:** Windows 7/8/8.1 (64-bit); Linux Ubuntu 20 Release; macOS;
- **PROCESSOR:** Intel Core i5-4690K(3.5 GHZ), AMD FX-8350 or similar.
- **RAM:** at least 8 GB
- **HARD DISK:** At least 512 GB of free hard disk space.
- **NETWORK CONNECTION:** Internet from 50 mb/sec.
- **Additional software:** DirectX 11.

## **Recommended requirements.**

- **OS:** Windows 7/8/8.1 (64-bit); Linux Ubuntu 20 Release; macOS;
- **RAM:** 16 GB
- **HARD DISK:** At least 512 GB of free hard disk space.
- **NETWORK CONNECTION:** Internet from 100 mb/sec.
- **Additional software:** DirectX 12.

# API for developers

**important! THE ARGUMENTS IN THE REQUESTS MUST BE SPECIFIED IN STRICT ORDER, IN ACCORDANCE WITH HOW DESCRIBED BELOW**

### (GET) "/api/balance/" - current token balance

Arguments:
1. address - account address
2. token - the short name of the token (its abbreviation)   

Request example:
```sh
/api/balance/?address=57LkviK66Hfx8TmSc3CzwQ66omHcqTAa1dKNKC7eTsJK&token=ORBC
```
Returns:   
- "wallet" - the account address
- "token" - the short name of the token (its abbreviation)
- "balance" - the current balance of the token

### (GET)"/api/create/cryptocontainer/" - creating a new cryptocontainer

Arguments:
1. pass - password (at least 6 characters)  

Request example:
```sh
/api/create/cryptocontainer/?pass=123123
```
Returns:   
+ "address" is the address of the created cryptographic
+ container "words" - 47 words for restoring the created cryptographic container. Save them and don't tell anyone!

### (GET) "/api/create/transaction/" - Create transaction

Arguments:
1. address - wallet address
2. pass - password
3. to - address of the recipient account
4. symbol - the short name of the token (abbreviation)
5. amount - quantity  

Request example:
```sh
/api/create/transaction/?address=8QjFv11MGJrZcmaxfp8RRER5aJEB3fLokZdYk78Fdqup&pass=123123&to=8QjFv11MGJrZcmaxfp8RRER5aJEB3fLokZdYk78Fdqup&symbol=ORBC&amount=12
```
Returns:  
**In case of successful creation of the transaction:**
- "success" = True - the success of the creation of the transaction
- "owner_sign" - the hash of the transaction signed with the private key of the creator of the transaction  

**In case of an error:**
- "success" = False
- "error" - description of the error (insufficient funds, non-existent token, etc.)

### (GET) "/api/check/transaction/" - Checking the transaction status

Arguments:
1. owner_sign - transaction hash signed with the private key of the transaction creator   

Request example:
```sh
/api/check/transaction/?owner_sign=2p3e8kpdTwRgbjVbfb9BCKGToQ3eizFkKYY2e3rvYDG9jAL8apT7PQKeP7Wnix87345Sb3riYKMA2rdnrDjYs7X
```
Returns:  
**If a transaction has been confirmed:**
- status = "confirmed"
- "owner_sign" hash transactions signed by private key of the originator of the transaction
- "unix_time" - the date and time of the transaction(in Unix format)
- "from" address for the account of the sender
- "to" address for the account of the recipient
- "amount" - the amount of the transferred funds
- "token" token(short name)   

**If a transaction with the specified hash does not exist or has not yet been confirmed:**
- "status" = "not confirmed or does not exist",

### (GET) "/api/create/token/" - Token creation

Arguments:
1. address - wallet address
2. pass - password
3. name - the full name of the token(not more than 32 characters, spaces and signs not allowed)
4. symbol - the short name of the token(abbreviation from 2 to 4 Latin letters, spaces and signs not allowed)
5. emission is the maximum amount of output(a positive integer more than 1 second)
6. capacity is the capacity(the number of decimal places from 2 to 8, inclusive)  
   
Request example:  
```sh
/api/create/token/?address=8QjFv11MGJrZcmaxfp8RRER5aJEB3fLokZdYk78Fdqup&pass=123123name=ORBISCoin&symbol=ORBC&emission=21000000&capacity=5
```
Returns:  
**In case of successful token creation:**  
- "success" = True - the success of the transaction creation
- "name" - the full name of the created token
- "symbol" - the short name of the created token
- "emission" - the maximum volume of issue of the created token
- "capacity" - the bit depth of the created token  

**In case of an error:**
- "success" = False
- "error" - error description (such token already exists, etc.)

### (GET) "/api/buy/OM/" - purchase OM

**Attention! Before executing the command, make sure that you are no longer an OM holder and that there is enough ORBC in your account to purchase it (1 OM = 10000 ORBC)**  

Arguments:
1. address - wallet address
2. pass - password  

Request example:
```sh
/api/buy/OM/?address=8QjFv11MGJrZcmaxfp8RRER5aJEB3fLokZdYk78Fdqup&pass=123123
``` 
Returns: 

**In case of a successful purchase of OM:**  
- "success" = True - the success of the purchase of OM  

**In case of an error:**
- "success" = False
- "error" - error description (failed to log in to the wallet, OM has already been purchased, not enough ORBC to purchase, etc.)

### (GET) "/api/checkom/" - checking whether the specified account is an OM holder 

Arguments:
1. address - account address 

Request example: 
```sh
/api/checkom/?address=8QjFv11MGJrZcmaxfp8RRER5aJEB3fLokZdYk78Fdqup
``` 
Returns:  

- "success" - the success of processing the request
- "om_holder" - the Boolean value of OM ownership of the specified account  

**If success = false:** 
- "error" - error description(a non-existent address is specified, etc.)

### (GET) "/api/address_balances/" - Request data about account tokens with their current balance 

Arguments:
1. address - account address  

Request example: 
```sh
/api/address_balances/?address=8QjFv11MGJrZcmaxfp8RRER5aJEB3fLokZdYk78Fdqup
```
Returns:  
- "balances" - an array of the following pairs:
- "symbol" - the short name of the token (abbreviation)
- "value" - the current balance of the token

### (GET)"/api/restore/cryptocontainer/keys/" - Restore the cryptocontainer using 47 words  

Arguments: 
1. keys - a list of keys (enumeration with underscores)
2. pass - a new password to access the recoverable cryptographic container 

Request example:   
```sh
/api/restore/cryptocontainer/keys/?keys=GRASS_JOIN_FRUIT_VIRUS_COIL_KNOW_HINT_WILL_HOVER_TRULY_PIGEON_PHONE_BROOM_NOSE_BUBBLE_TICKET_INCREASE_INTO_WISDOM_MINUTE_OMIT_MERGE_DESIGN_KIWI_BICYCLE_PELICAN_RAW_FALSE_EXTEND_MISS_RAIN_FUEL_MOUSE_MUSIC_MIMIC_STYLE_DOOR_SPEED_SEMINAR_ELDER_SONG_MASTER_ELECTRIC_RETREAT_FESTIVAL_SPATIAL_WOMAN&pass=111111
```
Returns:  
- "success" - the success of the operation
- "address" - the address of the recovered cryptographic container (in the case of "success" = "true")

### (GET)"/api/address_info/" - Request data about a specific account with the number of transactions for the specified tokens 

Arguments:
1. address - account address
2. tokens - a list of tokens (enumeration through underscores), or "all" to select all tokens.  

Request example: 
```sh
/api/address_info/?address=8QjFv11MGJrZcmaxfp8RRER5aJEB3fLokZdYk78Fdqup&tokens=TOROM_QUIPA_FOLEX
/api/address_info/?address=8QjFv11MGJrZcmaxfp8RRER5aJEB3fLokZdYk78Fdqup&tokens=all
```
Returns: 
- "address" - account address
- "id" - account id
- "trans_count" - the total number of transactions for the specified tokens
- "tokens_count" - the total number of tokens in an account with a positive current balance  

**If one token is specified, then the server response is supplemented with 3 more fields:**  
- "received" - total tokens received
- "sent" - total tokens sent
- "balance" - the balance of the token at the moment
- "symbol" - the short name of the token (abbreviation)

# Contact us
blockchainorbis@gmail.com



