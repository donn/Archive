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
    
    $userInfo = json_decode(file_get_contents('php://input'),true);
    $AppID = $userInfo['appID'];

    $verificationQuery = "
        Select count(*)
        from Contact_Profile
        where AppID = ".$AppID.";";

    $verificationResult = $conn->query($verificationQuery);

    if (!$verificationResult)
        die("VERIFICATION_QUERY_FAIL");

    $verificationResultGetter = $verificationResult->fetch_assoc();

    if ($verificationResultGetter['count(*)'] === 0)
        die("VERIFICATION_FAIL");
    
    foreach ($userInfo['contacts'] as $contact)
    {
        $name = $conn->real_escape_string($contact['displayName']);
        $phones = $contact['phoneNumbers'];
        $emails = $contact['emails'];
        $contactRegistered = FALSE;
        $ID = 0; //Minimum ID is 1

        //Check for emails and phones already existing. (Phones last, so priority.)
        foreach ($emails as $email)
        {
            $email = $conn->real_escape_string($email);
            $lookForEmailQuery =
	        "
		        Select ContactID
		        from Contact_Emails
		        where Email = '".$email."';";

	        $lookForEmailResult = $conn->query($lookForEmailQuery);
	        if (!($lookForEmailResult->num_rows === 0))
	        {
                $IDGetter = $lookForEmailResult->fetch_assoc();
                $ID = $IDGetter['ContactID'];
            }
        }
        foreach ($phones as $phone)
        {
            $phone = $conn->real_escape_string($phone);
            $lookForPhoneQuery =
	        "
		        Select ContactID
		        from Contact_Phones
		        where PhoneNo = '".$phone."';";

	        $lookForPhoneResult = $conn->query($lookForPhoneQuery);
	        if (!($lookForPhoneResult->num_rows === 0))
	        {
                $IDGetter = $lookForPhoneResult->fetch_assoc();
                $ID = $IDGetter['ContactID'];
            }
        }
        foreach ($phones as $phone)
        {
            if (!$contactRegistered)
            {
                $phone = $conn->real_escape_string($phone);
                $lookForPhoneQuery =
                "
		            Select ContactID
		            from Contact_Profile
                    where RegistrationPhoneNo = '".$phone."';";

	            $lookForPhoneResult = $conn->query($lookForPhoneQuery);
	            if (!($lookForPhoneResult->num_rows === 0))
	            {
                    $IDGetter = $lookForPhoneResult->fetch_assoc();
                    $ID = $IDGetter['ContactID'];
                }
                $contactRegistered = true;
            }
        }

        //If the ID is null, the user has not been previously registered
        if ($ID === 0)
        {
            $insertNewContactQuery =
            "
                Insert into Contact values
                    (null,'".$name."',null);
            ";

            if ($conn->query($insertNewContactQuery) != TRUE)
		    {
		    	die("CONTACT_INSERT_FAIL");
		    }		
		    $ID = $conn->insert_id;
        }

        //In any case, ~try~ to register everything, don't handle errors either
        foreach ($emails as $email)
        {
            $email = $conn->real_escape_string($email);
            $insertEmailQuery =
	        "
		        Insert into Contact_Emails values
                (".$ID.",'".$email."');";

	        $conn->query($insertEmailQuery);
        }
        foreach ($phones as $phone)
        {
            $phone = $conn->real_escape_string($phone);
            $insertPhoneQuery =
	        "
		        Insert into Contact_Phones values
                (".$ID.",'".$phone."');";

	        $conn->query($insertPhoneQuery);
        }
    }

    $conn->close();
    echo $AppID;
    die();

?>