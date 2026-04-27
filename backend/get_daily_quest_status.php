<?php
include_once("config.php");

if (!isset($_POST['user_id'])) {
    sendJsonResponse(array('status' => 'failed', 'message' => 'Missing user_id', 'data' => null));
    die();
}

$user_id = $_POST['user_id'];
$sql = "SELECT user_id, wellness_points, comfort_streak, last_quest_claim FROM tbl_users WHERE user_id = '$user_id' LIMIT 1";
$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $today = date('Y-m-d');

    $data = array(
        'wellness_points' => (int)$row['wellness_points'],
        'comfort_streak' => (int)$row['comfort_streak'],
        'last_quest_claim' => $row['last_quest_claim'],
        'claimed_today' => $row['last_quest_claim'] === $today,
    );

    sendJsonResponse(array('status' => 'success', 'data' => $data));
    die();
}

sendJsonResponse(array('status' => 'failed', 'message' => 'User not found', 'data' => null));

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
