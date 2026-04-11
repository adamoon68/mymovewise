<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("config.php");

$user_id = $_POST['user_id'];
$name = $_POST['name'];
$phone = $_POST['phone'];
$condition = $_POST['chronic_condition'];
$password = $_POST['password'];

// If password is provided, update it. If empty, keep old password.
if (!empty($password)) {
    $sql = "UPDATE tbl_users SET user_name = '$name', user_phone = '$phone', chronic_condition = '$condition', user_password = '$password' WHERE user_id = '$user_id'";
} else {
    $sql = "UPDATE tbl_users SET user_name = '$name', user_phone = '$phone', chronic_condition = '$condition' WHERE user_id = '$user_id'";
}

if ($conn->query($sql) === TRUE) {
    $response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>