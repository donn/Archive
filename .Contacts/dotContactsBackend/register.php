<?php
	//echo 'Current PHP version: ' . phpversion();
	error_reporting(E_ALL);
	ini_set('display_errors', 1);
	header("Content-Type: text/plain");	

	$servername = "";
	$username = "";
	$password = "";
	$dbname = "";

	$conn = new mysqli($servername,$username,$password,$dbname);

	if($conn->connect_errno)
	{
		echo $conn->connect_error;
		die("DBCONNECT_FAIL");
	}

	$userdata = json_decode(file_get_contents('php://input'),true);
	$countrySanitized = $conn->real_escape_string($userdata["country"]);
	$phoneNumberSanitized = $conn->real_escape_string($userdata["phoneNumber"]);
	$displayNameSanitized = $conn->real_escape_string($userdata["displayName"]);

	//Get default '?' city
	$defaultCityQuery =
	"
		Select Code
		from City
		where Name = '?'
		and CountryCode = 
		(
			Select Code
			from Country
			where PhoneCode = '".$countrySanitized."'
		);
	";
	
	$defaultCityResult = $conn->query($defaultCityQuery);
	$defaultCityGetter = $defaultCityResult->fetch_assoc();
	$defaultCity = $defaultCityGetter["Code"];
	
	$inContacts = false;
	$ID = 0;

	//Look for phone in Contact_Phones
	$lookForPhoneQuery =
	"
		Select ContactID
		from Contact_Phones
		where PhoneNo = '".$phoneNumberSanitized."';
	";

	$lookForPhoneResult = $conn->query($lookForPhoneQuery);
	
	//Depending on the result, insert or wait on update
	if ($lookForPhoneResult->num_rows === 0)
	{
		$contactInsert = 
		"
			Insert into Contact(DisplayName, CityCode)
				VALUES
				('".$displayNameSanitized."',".$defaultCity.");
		";
		
		if($conn->query($contactInsert) != TRUE)
		{
			die("CONTACT_INSERT_FAIL");
		}		
		$ID = $conn->insert_id;

		$phoneNoInsert = 
		"
			Insert into Contact_Phones
				Values
				('".$ID."','".$phoneNumberSanitized."');
		";

		if($conn->query($phoneNoInsert) != TRUE)
		{
			die("CONTACT_PHONES_INSERT_FAIL");
		}		
	}
	else
	{
		$inContacts = true;
		$IDGetter = $lookForPhoneResult->fetch_assoc();
		$ID = $IDGetter['ContactID'];
	}

	//MS Routine
	$Verification = rand();
	
	//Twilio. Replace with your favorite SMS API.
	require "/var/www/html/auc/twilio/twilio-php-master/Services/Twilio.php";

	$AccountSid = ""; // Your Account SID from www.twilio.com/console
	$AuthToken = "";   // Your Auth Token from www.twilio.com/console

	$client = new Services_Twilio($AccountSid, $AuthToken);

	$message = $client->account->messages->create(array(
    	"From" => "", // From a valid Twilio number
    	"To" => $userdata['phoneNumber'],   // Text this number
    	"Body" => "Your .Contacts verification code is: ".$Verification,
	));
	
	$quickDeleteQuery =
	"
		Delete from Register_Process
		where RegistrationPhoneNo = '".$phoneNumberSanitized."';
	";

	$conn->query($quickDeleteQuery);

	do
	{
		$AppID = rand();
		$registerProcessInsert = 
		"
			Insert into Register_Process
				values(".$AppID.",".$Verification.",".$ID.",'".$phoneNumberSanitized."','".$displayNameSanitized."',".$defaultCity.");
		";
		$registerProcessResult = $conn->query($registerProcessInsert);
		
	} while (!$registerProcessResult); //Maybe the AppID already exists...
	
	$conn->close();

	echo $AppID;
	die();
?>
