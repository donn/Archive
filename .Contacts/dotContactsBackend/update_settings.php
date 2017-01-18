<?php
//    header("Content-Type: application/json");
    error_reporting(E_ALL);
	ini_set('display_errors', 1);
    $servername = "";
	$username = "";
	$password = "";
	$dbname = "";


    $conn = new mysqli($servername,$username,$password,$dbname);
    if($conn->connect_errno){
        echo $conn->connect_error;
		exit("DBCONNECT_FAIL");
    }

    $settingsInfo = json_decode(file_get_contents('php://input'),true);

    $AppID = $settingsInfo['appID'];  

    $appIdQuery =
    "  
        SELECT Count(*) as count
        from Contact_Profile
        where AppID = ".$AppID.";
    ";

    $result = $conn->query($appIdQuery);
    $resultGetter = $result->fetch_assoc();
    if($resultGetter['count'] === 0)
    {
        die("INVALID_USER");
    }

    $chatChar = $settingsInfo['messagingAllowed'];
    $privacyChar = $settingsInfo['userInfoHidden'];

    $updateQuery =
    "
        Update Contact_Profile
        set
            IsMessagingAllowed = '".$chatChar."',
            IsUserInfoHidden = '".$privacyChar."'
        where AppID = ".$AppID.";
    ";
    $conn->query($updateQuery);
    $conn->close();

    echo $AppID;
    die();
?>
