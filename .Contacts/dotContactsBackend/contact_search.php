<?php
//    header("Content-Type: application/json");
    error_reporting(E_ALL);
	ini_set('', 1);
    $servername = "";
	$username = "";
	$password = "";
	$dbname = "";


    $conn = new mysqli($servername,$username,$password,$dbname);
    if($conn->connect_errno){
        echo $conn->connect_error;
		exit("DBCONNECT_FAIL");
    }

    $userdata = json_decode($_POST["USER_MSG"],true);

    $appIdQuery = "SELECT Count(*) as count from Contact_Profile
       where AppID = ".$userdata['AppID'].";";

    $result = $conn->query($appIdQuery);
    $resultGetter = $result->fetch_assoc();
    if($resultGetter['count'] === 0)
    {
        die("INVALID_USER");
    }

    $phoneno = $userdata['PhoneNo'];
    $numberQuery = "SELECT ContactID from Contact_Phones
        where PhoneNo Like '".$phoneno."%'";
       // echo $numberQuery;
    $result = $conn->query($numberQuery);
    $resultNo = $result->num_rows;

    $numberQuery = "SELECT RegistrationPhoneNo from Contact_Profile
        where RegistrationPhoneNo Like '%".$phoneno."%'
        and IsUserInfoHidden = 'N';";
    $numbers = $conn->query($numberQuery);
    $response = array();

    while ($row = $numbers->fetch_row()){
       $response[] = $row[0];
    }

    echo json_encode(ARRAY("PhoneNo"=>$response));

    $conn->close();
?>
