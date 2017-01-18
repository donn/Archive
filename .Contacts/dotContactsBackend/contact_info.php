<?php
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

    $getContactID =
    "
        SELECT ContactID from Contact_Profile where
        RegistrationPhoneNo = '".$_POST['PhoneNo']."'
        and ContactID not in
        (
            Select ContactID
            from Contact_Profile
            where IsUserInfoHidden = 'Y'
        );";

    $contactID = $conn->query($getContactID);

 
    if(mysqli_num_rows($contactID) === 0){
        $result = array("DisplayName"=>"",
                    "Location"=>"",
                    "PhoneNo"=>"");
        echo json_encode($result);
    }else{
        $contactID = $contactID->fetch_assoc()['ContactID'];

        $getContact = "SELECT CityCode,DisplayName from Contact where
            ID = ".$contactID;

        $temp = $conn->query($getContact)->fetch_assoc();

        $contactName = $temp['DisplayName'];
        $CityCode = $temp['CityCode'];
        $CityName = $conn->query("SELECT Name from
            City where Code = ".$CityCode)->fetch_assoc()['Name'];

        $getCountry = "SELECT Name,PhoneCode from Country where Code = ".$CityCode;
        $Country = $conn->query($getCountry)->fetch_assoc();

        if ($CityName === "?")
            $Location = $Country['Name'];
        else
            $Location = $CityName.", ".$Country['Name'];

        $email = "SELECT Email From Contact_Emails where ContactID = ".$contactID." LIMIT 1";
        $email = $conn->query($email)->fetch_row();

        if(sizeof($email) === 0){
            $email = "";
        }else{
           $email = $email[0];
        }
        $result = array("DisplayName"=>$contactName,
                        "Location"=>$Location,
                        "PhoneNo"=>$_POST['PhoneNo'],
                        "Email"=>$email);

        echo json_encode($result);
    }

    $conn->close();
?>
