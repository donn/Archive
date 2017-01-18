<?php
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
    
    //Check for verification existence   
    $verification = json_decode(file_get_contents('php://input'),true);
    $AppID = $verification['appID'];
    $verificationQuery = "
        Select count(*)
        from Register_Process
        where AppID = ".$AppID."
        and Verification = ".$verification['verification'].";";

    $verificationResult = $conn->query($verificationQuery);

    if (!$verificationResult)
        die("VERIFICATION_QUERY_FAIL");

    $verificationResultGetter = $verificationResult->fetch_assoc();

    if ($verificationResultGetter['count(*)'] === 0)
        die("VERIFICATION_FAIL");

    //Get registration data
    $registerProcessQuery =
    "
        Select *
        from Register_Process
        where AppID = ".$verification['appID'].";
    ";
   

    $registerProcessResult = $conn->query($registerProcessQuery);
    $registerProcessResultGetter = $registerProcessResult->fetch_assoc();
    
    $ContactID = $registerProcessResultGetter['ContactID'];
    $RegistrationPhoneNo = $registerProcessResultGetter['RegistrationPhoneNo'];

    //Update if user was found
    $lookForPhoneQuery =
	"
		Select ContactID
		from Contact_Phones
		where PhoneNo = '".$RegistrationPhoneNo."';
    ";

	$lookForPhoneResult = $conn->query($lookForPhoneQuery);

    if (!($lookForPhoneResult->num_rows === 0))
    {   
        $inContacts = true;
		$IDGetter = $lookForPhoneResult->fetch_assoc();
		$ID = $IDGetter['ContactID'];
		$updateQuery =
        "
			Update Contact
			set
				DisplayName = '".$registerProcessResultGetter['DisplayName']."',
				CityCode = ".$registerProcessResultGetter['CityCode']."
			where ID = ".$ID.";";
		if($conn->query($updateQuery) != TRUE)
		{
				die("CONTACT_UPDATE_FAIL");
		}
    }

    //Delete temporary registration, acknowledge user as registered
    $deleteQuery = "
        Delete from Register_Process
        where AppID = ".$AppID.";";
    
    $conn->query($deleteQuery);

    //Check whether to update or insert a new Contact_Profile
    $lookForProfileQuery =
	"
		Select RegistrationPhoneNo
		from Contact_Profile
		where RegistrationPhoneNo = '".$RegistrationPhoneNo."';";

	$lookForProfileResult = $conn->query($lookForProfileQuery);    
	
	//Depending on the result, update or insert	
	if ($lookForProfileResult->num_rows === 0)
	{
		$contactProfileInsert = "
            Insert into Contact_Profile
            values
                (".$ContactID.",".$AppID.",'".$RegistrationPhoneNo."','Y','N',null);";
		
		if($conn->query($contactProfileInsert) != TRUE)
		{
			die("CONTACT_PROFILE_INSERT_FAIL");
		}
	}
    else
    { 
        $contactProfileUpdate = "
            Update Contact_Profile
            set
                AppID = ".$AppID."
            where RegistrationPhoneNo = '".$RegistrationPhoneNo."';";

        if($conn->query($contactProfileUpdate) != TRUE)
		{
			die("CONTACT_PROFILE_UPDATE_FAIL");
		}
    }   

    $conn->close();
    
    echo($AppID);
    die();

?>