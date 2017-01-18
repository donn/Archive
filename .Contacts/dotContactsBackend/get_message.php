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

 //   $data = json_decode($_POST[REQUEST]);

    $messagesQuery =
    "
        SELECT SenderNumber, Message, Time
        FROM Message
        WHERE TargetNumber = '".$_POST['PhoneNo']."';
    ";
    //echo $query;

    $result = $conn->query($messagesQuery);

    $senderNumber = array();
    $message = array();
    $time = array();    

    while ($row = $result->fetch_row()){
       $senderNumber[] = $row[0];
       $message[] = $row[1];
       $time[] = $row[2];
    }

    echo json_encode(array('SenderNumber'=>$senderNumber,'Message'=>$message,'Time'=>$time));

    $delete = "DELETE FROM Message WHERE TargetNumber = '".$_POST['PhoneNo']."'";
    $conn->query($delete);

    $conn->close();
?>
