<?php
include_once("config.php");

if (!isset($_POST['user_id']) || !isset($_POST['completed_count']) || !isset($_POST['total_quests'])) {
    sendJsonResponse(array('status' => 'failed', 'message' => 'Missing required parameters', 'data' => null));
    die();
}

$user_id = $_POST['user_id'];
$completed_count = (int)$_POST['completed_count'];
$total_quests = (int)$_POST['total_quests'];

if ($total_quests <= 0 || $completed_count < $total_quests) {
    sendJsonResponse(array('status' => 'failed', 'message' => 'Complete all quests before claiming rewards', 'data' => null));
    die();
}

$sql = "SELECT wellness_points, comfort_streak, last_quest_claim FROM tbl_users WHERE user_id = '$user_id' LIMIT 1";
$result = $conn->query($sql);

if (!$result || $result->num_rows === 0) {
    sendJsonResponse(array('status' => 'failed', 'message' => 'User not found', 'data' => null));
    die();
}

$row = $result->fetch_assoc();
$today = date('Y-m-d');
$yesterday = date('Y-m-d', strtotime('-1 day'));
$last_claim = $row['last_quest_claim'];

if ($last_claim === $today) {
    sendJsonResponse(array('status' => 'failed', 'message' => 'Reward already claimed today', 'data' => null));
    die();
}

$current_points = (int)$row['wellness_points'];
$current_streak = (int)$row['comfort_streak'];

if ($last_claim === $yesterday) {
    $new_streak = $current_streak + 1;
} else {
    $new_streak = 1;
}

$base_reward = 40;
$streak_bonus = min(30, max(0, ($new_streak - 1) * 5));
$reward_earned = $base_reward + $streak_bonus;
$new_points = $current_points + $reward_earned;

$update = "UPDATE tbl_users 
           SET wellness_points = '$new_points',
               comfort_streak = '$new_streak',
               last_quest_claim = '$today'
           WHERE user_id = '$user_id'";

if ($conn->query($update) === TRUE) {
    $data = array(
        'reward_earned' => $reward_earned,
        'wellness_points' => $new_points,
        'comfort_streak' => $new_streak,
        'last_quest_claim' => $today,
        'claimed_today' => true,
    );

    sendJsonResponse(array('status' => 'success', 'data' => $data));
    die();
}

sendJsonResponse(array('status' => 'failed', 'message' => 'Unable to save reward', 'data' => null));

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
