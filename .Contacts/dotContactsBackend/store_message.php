<?php
    error_reporting(E_ALL);
    ini_set('display_errors', 1);

    define('SENDER_NUMBER', 'SenderNumber');
    define("TABLE","Message");
    define('MESSAGE', 'Message');
    define('TARGET_NUMBER', 'TargetNumber');
    define('TIME', 'Time');
    define('REQUEST','Data');

    $servername = "";
    $username = "";
    $password = "";
    $dbname = "";

    $conn = new mysqli($servername,$username,$password,$dbname);
    if($conn->connect_errno){
        echo $conn->connect_error;
        exit("DBCONNECT_FAIL");
    }

    $data = $_POST[REQUEST];
    $data = json_decode($data,true);

    $checkTargetQuery =
    "
        Select ContactID
        from Contact_Profile
        where RegistrationPhoneNo = '".$data[TARGET_NUMBER]."'
        and IsMessagingAllowed = 'Y';
    ";

   $checkTargetResult = $conn->query($checkTargetQuery);

   if ($checkTargetResult->num_rows === 0)
   {
        $query = "INSERT INTO ".TABLE."(".SENDER_NUMBER.",".MESSAGE.",".
        TARGET_NUMBER.") VALUES('".$data[TARGET_NUMBER]."','This user has messaging disabled or does not exist.','".$data[SENDER_NUMBER]."')";    
        $conn->query($query);
        $conn->close();
        die();
   }
   else
   {
        $query = "INSERT INTO ".TABLE."(".SENDER_NUMBER.",".MESSAGE.",".
        TARGET_NUMBER.") VALUES('".$data[SENDER_NUMBER]."','".$data[MESSAGE].
        "','".$data[TARGET_NUMBER]."')";

        $conn->query($query);
        $conn->close();
        die();
   }
?>
