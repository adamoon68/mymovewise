-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 11, 2026 at 11:36 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mymovewise_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `tbl_exercises`
--

CREATE TABLE `tbl_exercises` (
  `exercise_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `type` varchar(50) NOT NULL,
  `tags` varchar(255) NOT NULL,
  `video_link` text DEFAULT NULL,
  `difficulty_level` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_exercises`
--

INSERT INTO `tbl_exercises` (`exercise_id`, `name`, `description`, `type`, `tags`, `video_link`, `difficulty_level`) VALUES
(5, '30 Barbell Floor Wiper', 'The barbell floor wiper is a core exercise in which the barbell is held in the locked-out position of a floor press, and the hips and legs are rotated side to side. It targets the oblique muscles of the lateral abdomen, but is also seriously challenging to the deep core and rectus abdominis or \"six-pack\" muscles.', 'Strength', 'Patch Data', 'https://youtu.be/Tili1UX_mJk?si=eXE3_atK3QpPgYMO', 'Intermediate'),
(6, 'Frog Hops', 'jump like a frog', 'Stretching', 'Patch Data', '', 'Beginner'),
(7, 'Holman Right Leg Donkey Kick', 'donkey kick', 'Strength', 'Patch Data', '', 'Intermediate');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_history`
--

CREATE TABLE `tbl_history` (
  `history_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `exercise_name` varchar(255) NOT NULL,
  `type` varchar(50) NOT NULL,
  `date_completed` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_history`
--

INSERT INTO `tbl_history` (`history_id`, `user_id`, `exercise_name`, `type`, `date_completed`) VALUES
(1, 2, 'Custom Medium Session', 'Mixed', '2026-01-11 14:34:42'),
(2, 3, 'Return Push from Stance', 'Plyometrics', '2026-01-11 17:18:55'),
(3, 2, 'HM Right Side-Kick', 'Stretching', '2026-01-11 18:14:44'),
(4, 2, 'Knees tucked crunch', 'Strength', '2026-01-11 18:14:50'),
(5, 2, 'UP Chin-Up', 'Strength', '2026-01-11 18:14:53');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_users`
--

CREATE TABLE `tbl_users` (
  `user_id` int(11) NOT NULL,
  `user_name` varchar(255) NOT NULL,
  `user_email` varchar(255) NOT NULL,
  `user_password` varchar(40) NOT NULL,
  `user_phone` varchar(20) NOT NULL,
  `chronic_condition` varchar(255) DEFAULT 'None',
  `user_role` varchar(10) DEFAULT 'user',
  `user_datereg` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_users`
--

INSERT INTO `tbl_users` (`user_id`, `user_name`, `user_email`, `user_password`, `user_phone`, `chronic_condition`, `user_role`, `user_datereg`) VALUES
(1, 'System Admin', 'admin@gmail.com', 'f865b53623b121fd34ee5426c792e5c33af8c227', '0123456789', 'None', 'admin', '2026-01-11 14:03:06'),
(2, 'Adam', 'adam@gmail.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0195875589', 'Arthritis', 'user', '2026-01-11 14:34:10'),
(3, 'Adam2', 'adam2@gmail.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0195875588', 'None', 'user', '2026-01-11 17:16:41');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_exercises`
--
ALTER TABLE `tbl_exercises`
  ADD PRIMARY KEY (`exercise_id`);

--
-- Indexes for table `tbl_history`
--
ALTER TABLE `tbl_history`
  ADD PRIMARY KEY (`history_id`);

--
-- Indexes for table `tbl_users`
--
ALTER TABLE `tbl_users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_email` (`user_email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tbl_exercises`
--
ALTER TABLE `tbl_exercises`
  MODIFY `exercise_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `tbl_history`
--
ALTER TABLE `tbl_history`
  MODIFY `history_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `tbl_users`
--
ALTER TABLE `tbl_users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
