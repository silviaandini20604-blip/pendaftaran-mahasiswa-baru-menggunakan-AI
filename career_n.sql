-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 19, 2025 at 05:37 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `career_n`
--

-- --------------------------------------------------------

--
-- Table structure for table `majors`
--

CREATE TABLE `majors` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `category` enum('SMK','UNIVERSITY') NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `majors`
--

INSERT INTO `majors` (`id`, `name`, `category`, `description`) VALUES
(1, 'Teknik Informatika', 'UNIVERSITY', 'Jurusan programming dan software development'),
(2, 'Sistem Informasi', 'UNIVERSITY', 'Jurusan bisnis dan teknologi informasi'),
(3, 'Teknik Mesin', 'UNIVERSITY', 'Jurusan permesinan dan manufacturing'),
(4, 'Akuntansi', 'UNIVERSITY', 'Jurusan keuangan dan akuntansi'),
(5, 'Rekayasa Perangkat Lunak', 'SMK', 'Jurusan programming tingkat menengah'),
(6, 'Teknik Kendaraan Ringan', 'SMK', 'Jurusan otomotif'),
(7, 'Multimedia', 'SMK', 'Jurusan design dan multimedia'),
(8, 'Akuntansi', 'SMK', 'Jurusan akuntansi tingkat menengah');

-- --------------------------------------------------------

--
-- Table structure for table `test_results`
--

CREATE TABLE `test_results` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `ocean_score_openness` float DEFAULT NULL,
  `ocean_score_conscientiousness` float DEFAULT NULL,
  `ocean_score_extraversion` float DEFAULT NULL,
  `ocean_score_agreeableness` float DEFAULT NULL,
  `ocean_score_neuroticism` float DEFAULT NULL,
  `aptitude_score` int(11) DEFAULT NULL,
  `passed` tinyint(1) DEFAULT NULL,
  `recommended_major_id` int(11) DEFAULT NULL,
  `chosen_major_id` int(11) DEFAULT NULL,
  `test_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `email`, `full_name`, `created_at`) VALUES
(1, 'SuS', '123', 'dmsadm@gmail.com', 'Susilo', '2025-11-19 06:17:23');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `majors`
--
ALTER TABLE `majors`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `test_results`
--
ALTER TABLE `test_results`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `recommended_major_id` (`recommended_major_id`),
  ADD KEY `chosen_major_id` (`chosen_major_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `majors`
--
ALTER TABLE `majors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `test_results`
--
ALTER TABLE `test_results`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `test_results`
--
ALTER TABLE `test_results`
  ADD CONSTRAINT `test_results_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `test_results_ibfk_2` FOREIGN KEY (`recommended_major_id`) REFERENCES `majors` (`id`),
  ADD CONSTRAINT `test_results_ibfk_3` FOREIGN KEY (`chosen_major_id`) REFERENCES `majors` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
