<?php
include_once("config.php");

if (!isset($_POST['user_id'])) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

$userid = $_POST['user_id'];

$sql = "SELECT * FROM tbl_history WHERE user_id = '$userid' ORDER BY date_completed DESC";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $historydata = array();
    while ($row = $result->fetch_assoc()) {
        $record = array();
        $record['history_id'] = $row['history_id'];
        $record['exercise_name'] = $row['exercise_name'];
        $record['type'] = $row['type'];
        $record['date_completed'] = $row['date_completed'];
        array_push($historydata, $record);
    }
    $response = array('status' => 'success', 'data' => $historydata);
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