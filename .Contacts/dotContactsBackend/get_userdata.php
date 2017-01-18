<?php
    class GlobalInfo
    {
        public $appID;
        public $contactID;
        public $displayName;
        public $registrationPhoneNumber;
        public $cityCode;
        public $countryCode;
        public $userInfoHidden;
        public $messagingAllowed;
    }

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
    
    $AppID = file_get_contents('php://input');
    
    $verificationQuery =
    "
        Select ContactID, RegistrationPhoneNo, IsUserInfoHidden, IsMessagingAllowed
        from Contact_Profile
        where AppID = ".$AppID.";
    ";

    $verificationResult = $conn->query($verificationQuery);

    if (!$verificationResult)
        die("VERIFICATION_QUERY_FAIL");

    if ($verificationResult->num_rows === 0)
        die("VERIFICATION_FAIL");

    $verificationResultGetter = $verificationResult->fetch_assoc();

    $info = new GlobalInfo();
    $info->appID = $AppID;
    $info->contactID = $verificationResultGetter['ContactID'];
    $info->registrationPhoneNumber = $verificationResultGetter['RegistrationPhoneNo'];
    $info->userInfoHidden = $verificationResultGetter['IsUserInfoHidden'];
    $info->messagingAllowed = $verificationResultGetter['IsMessagingAllowed'];

    $contactQuery =
    "
        Select DisplayName, CityCode
        from Contact
        where ID = ".$info->contactID.";    
    ";

    $contactResult = $conn->query($contactQuery);

    if (!$contactResult)
        die("CONTACT_QUERY_FAIL");

    //Can't get num_rows === 0 or else the database is broken and that's a problem bigger than what PHP can handle really

    $contactResultGetter = $contactResult->fetch_assoc();
    $info->displayName = $contactResultGetter['DisplayName'];
    $info->cityCode = $contactResultGetter['CityCode'];

    $countryQuery =
    "
        Select CountryCode
        from City
        where Code = ".$info->cityCode.";    
    ";

    $countryResult = $conn->query($countryQuery);

    if (!$countryResult)
        die("COUNTRY_QUERY_FAIL");

    $countryResultGetter = $countryResult->fetch_assoc();

    $info->countryCode = $countryResultGetter['CountryCode'];
    $conn->close();

    echo json_encode($info);
    die();
?>