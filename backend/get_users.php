<?php
include_once("config.php");

$sql = "SELECT user_id, user_name, user_email, user_phone, chronic_condition, user_role, user_datereg
        FROM tbl_users
        ORDER BY user_name ASC";
$result = $conn->query($sql);

$users = array();

if ($result) {
    while ($row = $result->fetch_assoc()) {
        $users[] = $row;
    }
}

sendJsonResponse(array('status' => 'success', 'data' => $users));

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
