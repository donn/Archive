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
    
    $AppID = file_get_contents('php://input');

    //Check for verification existence
    $verificationQuery = "
        Select AppID
        from Contact_Profile
        where AppID = ".$AppID.";";

    $verificationResult = $conn->query($verificationQuery);

    if (!$verificationResult)
        die("VERIFICATION_QUERY_FAIL");

    if ($verificationResult->num_rows === 0)
        die("VERIFICATION_FAIL");

    $conn->close();
    echo $AppID;
    die();

?>