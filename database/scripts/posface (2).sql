-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 30-07-2025 a las 16:40:24
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `posface`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_documento_administrativo_insert` (IN `p_fk_id_estado` INT, IN `p_fk_id_tipo` INT, IN `p_fk_id_usuario` INT, IN `p_nombre_documento` VARCHAR(100), IN `p_descripcion` TEXT, IN `p_ruta_archivo` VARCHAR(255), IN `p_fecha_subida` DATE)   BEGIN
  INSERT INTO documento_administrativo (fk_id_estado, fk_id_tipo, fk_id_usuario, nombre_documento, descripcion, ruta_archivo, fecha_subida)
  VALUES (p_fk_id_estado, p_fk_id_tipo, p_fk_id_usuario, p_nombre_documento, p_descripcion, p_ruta_archivo, p_fecha_subida);
  
  INSERT INTO auditoria (fk_id_usuario, accion, tabla_afectada, registro_id, descripcion)
  VALUES (p_fk_id_usuario, 'INSERT', 'documento_administrativo', LAST_INSERT_ID(), CONCAT('Subida de documento: ', p_nombre_documento));
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_pagos_terna_insert` (IN `p_fk_id_usuario` INT, IN `p_fk_id_estado_pago` INT, IN `p_fk_id_documento` INT, IN `p_monto` DECIMAL(10,2), IN `p_fecha_entrega` DATE, IN `p_observaciones` TEXT)   BEGIN
  INSERT INTO pagos_terna (fk_id_usuario, fk_id_estado_pago, fk_id_documento, monto, fecha_entrega, observaciones)
  VALUES (p_fk_id_usuario, p_fk_id_estado_pago, p_fk_id_documento, p_monto, p_fecha_entrega, p_observaciones);
  
  INSERT INTO auditoria (fk_id_usuario, accion, tabla_afectada, registro_id, descripcion)
  VALUES (p_fk_id_usuario, 'INSERT', 'pagos_terna', LAST_INSERT_ID(), 'Registro de pago de terna');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tesis_insert` (IN `p_fk_id_estado` INT, IN `p_fk_id_usuario` INT, IN `p_titulo` VARCHAR(255), IN `p_autor` VARCHAR(100), IN `p_carrera` VARCHAR(100), IN `p_tema` VARCHAR(255), IN `p_anio` YEAR, IN `p_ruta_archivo` VARCHAR(255), IN `p_fecha_subida` DATE)   BEGIN
  INSERT INTO tesis (fk_id_estado, fk_id_usuario, titulo, autor, carrera, tema, anio, ruta_archivo, fecha_subida)
  VALUES (p_fk_id_estado, p_fk_id_usuario, p_titulo, p_autor, p_carrera, p_tema, p_anio, p_ruta_archivo, p_fecha_subida);
  
  INSERT INTO auditoria (fk_id_usuario, accion, tabla_afectada, registro_id, descripcion)
  VALUES (p_fk_id_usuario, 'INSERT', 'tesis', LAST_INSERT_ID(), CONCAT('Subida de tesis: ', p_titulo));
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuario_insert` (IN `p_fk_id_persona` INT, IN `p_fk_id_empresa` INT, IN `p_usuario` VARCHAR(100), IN `p_contrasena` VARCHAR(255), IN `p_correo` VARCHAR(100), IN `p_estado` TINYINT(1), IN `p_usr_add` INT)   BEGIN
  INSERT INTO usuario (fk_id_persona, fk_id_empresa, usuario, contrasena, correo, estado, usr_add)
  VALUES (p_fk_id_persona, p_fk_id_empresa, p_usuario, p_contrasena, p_correo, p_estado, p_usr_add);
  
  INSERT INTO auditoria (fk_id_usuario, accion, tabla_afectada, registro_id, descripcion)
  VALUES (p_usr_add, 'INSERT', 'usuario', LAST_INSERT_ID(), CONCAT('Creación de usuario: ', p_usuario));
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_verificacion_2fa_delete_expired` ()   BEGIN
  DELETE FROM verificacion_2fa
  WHERE fecha_expiracion < NOW();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_verificacion_2fa_insert` (IN `p_fk_id_usuario` INT, IN `p_correo` VARCHAR(100), IN `p_codigo` VARCHAR(6))   BEGIN
  INSERT INTO verificacion_2fa (fk_id_usuario, correo, codigo, fecha_expiracion, usado)
  VALUES (p_fk_id_usuario, p_correo, p_codigo, DATE_ADD(NOW(), INTERVAL 15 MINUTE), 0);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_verificacion_2fa_select` (IN `p_correo` VARCHAR(100), IN `p_codigo` VARCHAR(6))   BEGIN
  SELECT * FROM verificacion_2fa
  WHERE correo = p_correo
  AND codigo = p_codigo
  AND fecha_expiracion > NOW()
  AND usado = 0;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_verificacion_2fa_update` (IN `p_id_verificacion` INT)   BEGIN
  UPDATE verificacion_2fa
  SET usado = 1
  WHERE id_verificacion = p_id_verificacion;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `accesos`
--

CREATE TABLE `accesos` (
  `id_acceso` bigint(20) NOT NULL,
  `fk_id_rol` bigint(20) NOT NULL,
  `fk_id_objeto` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `permiso` tinyint(1) DEFAULT 0,
  `permiso_ver` tinyint(1) NOT NULL DEFAULT 0,
  `permiso_editar` tinyint(1) NOT NULL DEFAULT 0,
  `permiso_agregar` tinyint(1) NOT NULL DEFAULT 0,
  `permiso_eliminar` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `accesos`
--

INSERT INTO `accesos` (`id_acceso`, `fk_id_rol`, `fk_id_objeto`, `created_at`, `updated_at`, `permiso`, `permiso_ver`, `permiso_editar`, `permiso_agregar`, `permiso_eliminar`) VALUES
(175, 2, 3, '2025-07-21 09:31:05', '2025-07-21 09:31:05', 1, 1, 0, 0, 0),
(176, 2, 12, '2025-07-21 09:31:05', '2025-07-21 09:31:05', 1, 1, 1, 1, 1),
(177, 5, 3, '2025-07-21 11:24:52', '2025-07-21 11:24:52', 1, 1, 0, 0, 0),
(178, 5, 5, '2025-07-21 11:24:52', '2025-07-21 11:24:52', 1, 1, 0, 0, 0),
(179, 5, 12, '2025-07-21 11:24:52', '2025-07-21 11:24:52', 1, 1, 1, 1, 1),
(180, 5, 16, '2025-07-21 11:24:52', '2025-07-21 11:24:52', 1, 1, 1, 1, 1),
(183, 7, 3, '2025-07-22 03:21:59', '2025-07-22 03:21:59', 1, 1, 1, 1, 1),
(184, 7, 4, '2025-07-22 03:21:59', '2025-07-22 03:21:59', 1, 1, 1, 1, 1),
(188, 1, 3, '2025-07-22 10:48:17', '2025-07-22 10:48:17', 1, 1, 1, 1, 1),
(189, 1, 5, '2025-07-22 10:48:17', '2025-07-22 10:48:17', 1, 1, 1, 1, 1),
(190, 1, 13, '2025-07-22 10:48:17', '2025-07-22 10:48:17', 1, 1, 1, 1, 0),
(195, 6, 3, '2025-07-29 05:04:29', '2025-07-29 05:04:29', 1, 1, 1, 1, 1),
(196, 6, 17, '2025-07-29 05:04:29', '2025-07-29 05:04:29', 1, 1, 1, 1, 1),
(197, 6, 19, '2025-07-29 05:04:29', '2025-07-29 05:04:29', 1, 1, 1, 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `acuses`
--

CREATE TABLE `acuses` (
  `id_acuse` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `fk_id_usuario_remitente` int(11) NOT NULL,
  `fk_id_usuario_destinatario` int(11) NOT NULL,
  `estado` enum('enviado','recibido','pendiente') DEFAULT 'pendiente',
  `fecha_envio` datetime NOT NULL,
  `fecha_recepcion` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `fk_id_acuse_original` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `acuses`
--

INSERT INTO `acuses` (`id_acuse`, `titulo`, `descripcion`, `fk_id_usuario_remitente`, `fk_id_usuario_destinatario`, `estado`, `fecha_envio`, `fecha_recepcion`, `created_at`, `updated_at`, `fk_id_acuse_original`) VALUES
(9, 'prueba', 'xd', 22, 15, 'recibido', '2025-07-07 09:39:13', '2025-07-07 09:41:15', '2025-07-07 15:39:13', '2025-07-07 15:41:15', NULL),
(10, 'Entrega de documentos', 'contratos', 25, 22, 'recibido', '2025-07-21 05:12:55', '2025-07-21 05:13:45', '2025-07-17 07:02:49', '2025-07-21 11:13:45', NULL),
(11, 'always', 'cantando mis temas', 15, 22, 'recibido', '2025-07-21 03:36:10', '2025-07-21 03:36:24', '2025-07-21 09:36:10', '2025-07-21 09:36:24', NULL),
(12, 'Entrega de expediente', 'Expediente de Sara Connor', 22, 25, 'recibido', '2025-07-21 05:24:04', '2025-07-21 05:26:30', '2025-07-21 11:24:04', '2025-07-21 11:26:30', NULL),
(13, 'lapices', 'asfafa', 22, 25, 'recibido', '2025-07-21 06:16:06', '2025-07-21 06:25:20', '2025-07-21 12:16:06', '2025-07-21 12:25:20', NULL),
(14, 'lapices', 'sghhsh', 22, 15, 'recibido', '2025-07-21 06:59:32', '2025-07-21 07:00:02', '2025-07-21 12:26:04', '2025-07-21 13:00:02', NULL),
(15, 'lapices', 'afasf', 22, 15, 'recibido', '2025-07-21 06:29:02', '2025-07-21 07:00:09', '2025-07-21 12:29:02', '2025-07-21 13:00:09', NULL),
(18, 'fafa', 'fasfafs', 22, 15, 'recibido', '2025-07-21 06:50:58', '2025-07-21 07:00:05', '2025-07-21 12:50:58', '2025-07-21 13:00:05', NULL),
(19, 'Recio', NULL, 25, 22, 'recibido', '2025-07-22 05:12:50', '2025-07-22 22:58:45', '2025-07-22 11:01:31', '2025-07-23 04:58:45', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `acuses_adjuntos`
--

CREATE TABLE `acuses_adjuntos` (
  `id_adjunto` int(11) NOT NULL,
  `fk_id_acuse` int(11) NOT NULL,
  `tipo` enum('documento','imagen') NOT NULL,
  `nombre_archivo` varchar(255) NOT NULL,
  `ruta` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `acuses_adjuntos`
--

INSERT INTO `acuses_adjuntos` (`id_adjunto`, `fk_id_acuse`, `tipo`, `nombre_archivo`, `ruta`, `created_at`, `updated_at`) VALUES
(3, 12, 'documento', 'CV_HiavertMaldonado.docx', 'adjuntos_acuses/documentos/1753075444_CV_HiavertMaldonado.docx', '2025-07-21 11:24:05', '2025-07-21 11:24:05'),
(4, 12, 'imagen', 'Captura de pantalla 2025-05-27 140613.png', 'adjuntos_acuses/imagenes/1753075445_Captura de pantalla 2025-05-27 140613.png', '2025-07-21 11:24:05', '2025-07-21 11:24:05'),
(5, 19, 'documento', 'CurriculumHiavertMaldonado.pdf', 'adjuntos_acuses/documentos/1753160493_CurriculumHiavertMaldonado.pdf', '2025-07-22 11:01:34', '2025-07-22 11:01:34'),
(6, 19, 'imagen', 'WhatsApp Image 2024-02-09 at 6.34.34 PM.jpeg', 'adjuntos_acuses/imagenes/1753160494_WhatsApp Image 2024-02-09 at 6.34.34 PM.jpeg', '2025-07-22 11:01:34', '2025-07-22 11:01:34');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `acuses_transferencias`
--

CREATE TABLE `acuses_transferencias` (
  `id_transferencia` int(11) NOT NULL,
  `fk_id_acuse` int(11) NOT NULL,
  `fk_id_usuario_origen` int(11) NOT NULL,
  `fk_id_usuario_destino` int(11) NOT NULL,
  `fecha_transferencia` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `acuses_transferencias`
--

INSERT INTO `acuses_transferencias` (`id_transferencia`, `fk_id_acuse`, `fk_id_usuario_origen`, `fk_id_usuario_destino`, `fecha_transferencia`, `created_at`, `updated_at`) VALUES
(4, 10, 15, 25, '2025-07-21 05:11:26', '2025-07-21 11:11:26', '2025-07-21 11:11:26'),
(5, 10, 25, 22, '2025-07-21 05:12:55', '2025-07-21 11:12:55', '2025-07-21 11:12:55'),
(7, 14, 22, 15, '2025-07-21 06:59:32', '2025-07-21 12:59:32', '2025-07-21 12:59:32'),
(8, 19, 25, 22, '2025-07-22 05:12:50', '2025-07-22 11:12:50', '2025-07-22 11:12:50');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria`
--

CREATE TABLE `auditoria` (
  `id_auditoria` int(11) NOT NULL,
  `fk_id_usuario` int(11) NOT NULL,
  `accion` varchar(100) NOT NULL,
  `tabla_afectada` varchar(100) DEFAULT NULL,
  `registro_id` int(11) DEFAULT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bitacoras`
--

CREATE TABLE `bitacoras` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `usuario_nombre` varchar(255) DEFAULT NULL,
  `accion` varchar(255) NOT NULL,
  `modulo` varchar(255) NOT NULL,
  `registro_id` bigint(20) UNSIGNED DEFAULT NULL,
  `datos_antes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`datos_antes`)),
  `datos_despues` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`datos_despues`)),
  `ip` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `bitacoras`
--

INSERT INTO `bitacoras` (`id`, `user_id`, `usuario_nombre`, `accion`, `modulo`, `registro_id`, `datos_antes`, `datos_despues`, `ip`, `created_at`, `updated_at`) VALUES
(1, 15, 'Usuario Admin', 'actualizar_permisos', 'Rol', 1, '[{\"id_acceso\":99,\"fk_id_rol\":1,\"fk_id_objeto\":3,\"created_at\":\"2025-07-03T14:56:20.000000Z\",\"updated_at\":\"2025-07-03T14:56:20.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":100,\"fk_id_rol\":1,\"fk_id_objeto\":5,\"created_at\":\"2025-07-03T14:56:20.000000Z\",\"updated_at\":\"2025-07-03T14:56:20.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":5,\"nombre_objeto\":\"TareasDocumentales\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de tareas documentales\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":101,\"fk_id_rol\":1,\"fk_id_objeto\":6,\"created_at\":\"2025-07-03T14:56:20.000000Z\",\"updated_at\":\"2025-07-03T14:56:20.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":6,\"nombre_objeto\":\"TareasTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de tareas de tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":102,\"fk_id_rol\":1,\"fk_id_objeto\":7,\"created_at\":\"2025-07-03T14:56:20.000000Z\",\"updated_at\":\"2025-07-03T14:56:20.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":7,\"nombre_objeto\":\"Usuarios\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de usuarios\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":103,\"fk_id_rol\":1,\"fk_id_objeto\":8,\"created_at\":\"2025-07-03T14:56:20.000000Z\",\"updated_at\":\"2025-07-03T14:56:20.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":8,\"nombre_objeto\":\"Roles\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de roles y permisos\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '[{\"id_acceso\":104,\"fk_id_rol\":1,\"fk_id_objeto\":3,\"created_at\":\"2025-07-03T20:19:19.000000Z\",\"updated_at\":\"2025-07-03T20:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":105,\"fk_id_rol\":1,\"fk_id_objeto\":4,\"created_at\":\"2025-07-03T20:19:19.000000Z\",\"updated_at\":\"2025-07-03T20:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":106,\"fk_id_rol\":1,\"fk_id_objeto\":5,\"created_at\":\"2025-07-03T20:19:19.000000Z\",\"updated_at\":\"2025-07-03T20:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":5,\"nombre_objeto\":\"TareasDocumentales\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de tareas documentales\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":107,\"fk_id_rol\":1,\"fk_id_objeto\":6,\"created_at\":\"2025-07-03T20:19:19.000000Z\",\"updated_at\":\"2025-07-03T20:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":6,\"nombre_objeto\":\"TareasTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de tareas de tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":108,\"fk_id_rol\":1,\"fk_id_objeto\":7,\"created_at\":\"2025-07-03T20:19:19.000000Z\",\"updated_at\":\"2025-07-03T20:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":7,\"nombre_objeto\":\"Usuarios\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de usuarios\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":109,\"fk_id_rol\":1,\"fk_id_objeto\":8,\"created_at\":\"2025-07-03T20:19:19.000000Z\",\"updated_at\":\"2025-07-03T20:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":8,\"nombre_objeto\":\"Roles\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de roles y permisos\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":110,\"fk_id_rol\":1,\"fk_id_objeto\":9,\"created_at\":\"2025-07-03T20:19:19.000000Z\",\"updated_at\":\"2025-07-03T20:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":9,\"nombre_objeto\":\"Reportes\",\"tipo_objeto\":\"Reporte\",\"descripcion_objeto\":\"Generaci\\u00f3n de reportes\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":111,\"fk_id_rol\":1,\"fk_id_objeto\":10,\"created_at\":\"2025-07-03T20:19:19.000000Z\",\"updated_at\":\"2025-07-03T20:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":10,\"nombre_objeto\":\"Cronograma\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de cronogramas\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T10:16:01.000000Z\",\"updated_at\":\"2025-06-25T10:16:01.000000Z\"}},{\"id_acceso\":112,\"fk_id_rol\":1,\"fk_id_objeto\":11,\"created_at\":\"2025-07-03T20:19:19.000000Z\",\"updated_at\":\"2025-07-03T20:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":11,\"nombre_objeto\":\"Bitacora\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Vista general de todos los cambios que se realizan.\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T10:16:01.000000Z\",\"updated_at\":\"2025-07-01T21:15:49.000000Z\"}}]', '127.0.0.1', '2025-07-04 02:19:19', '2025-07-04 02:19:19'),
(2, 15, 'Usuario Admin', 'crear', 'Usuario', 21, NULL, '{\"usuario\":\"Yanior-MF\",\"nombres\":\"Yanior Josiel\",\"apellidos\":\"Munguia Figueroa\",\"email\":\"figueroajosiel@gmail.com\",\"identidad\":\"1519-1998-00197\",\"estado\":\"0\",\"updated_at\":\"2025-07-03T20:20:45.000000Z\",\"created_at\":\"2025-07-03T20:20:45.000000Z\",\"id_usuario\":21}', '127.0.0.1', '2025-07-04 02:20:51', '2025-07-04 02:20:51'),
(3, 21, 'Yanior Josiel Munguia Figueroa', 'crear', 'Tarea', 16, NULL, '{\"nombre\":\"revisa documentos del docente Juan\",\"descripcion\":\"revisa\",\"fk_id_usuario_asignado\":\"21\",\"fk_id_usuario_creador\":\"21\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-03\",\"fecha_vencimiento\":\"2025-07-13\",\"updated_at\":\"2025-07-03T20:28:05.000000Z\",\"created_at\":\"2025-07-03T20:28:05.000000Z\",\"id_tarea\":16}', '127.0.0.1', '2025-07-04 02:28:05', '2025-07-04 02:28:05'),
(4, 21, 'Yanior Josiel Munguia Figueroa', 'cargar_documento', 'Documento', 5, NULL, '{\"nombre_documento\":\"qr_DIV01.png\",\"descripcion\":null,\"ruta_archivo\":\"tareas_documentos\\/WKvN1cLNBJ3Z4uJE6sYWYyyY9B1QskgiEOLBvQB5.png\",\"fecha_subida\":\"2025-07-03T20:29:18.989786Z\",\"fk_id_usuario\":21,\"fk_id_tipo\":\"1\",\"updated_at\":\"2025-07-03T20:29:18.000000Z\",\"created_at\":\"2025-07-03T20:29:18.000000Z\",\"id_documento\":5}', '127.0.0.1', '2025-07-04 02:29:19', '2025-07-04 02:29:19'),
(5, 21, 'Yanior Josiel Munguia Figueroa', 'asociar_documento', 'Tarea', 16, NULL, '{\"id_documento\":5}', '127.0.0.1', '2025-07-04 02:29:19', '2025-07-04 02:29:19'),
(6, 21, 'Yanior Josiel Munguia Figueroa', 'eliminar', 'Tarea', 16, '{\"id_tarea\":16,\"fk_id_usuario_asignado\":21,\"fk_id_usuario_creador\":21,\"nombre\":\"revisa documentos del docente Juan\",\"descripcion\":\"revisa\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-03\",\"fecha_vencimiento\":\"2025-07-13\",\"created_at\":\"2025-07-03T20:28:05.000000Z\",\"updated_at\":\"2025-07-03T20:28:05.000000Z\",\"deleted_at\":null}', NULL, '127.0.0.1', '2025-07-04 02:29:36', '2025-07-04 02:29:36'),
(7, 15, 'Usuario Admin', 'editar', 'Usuario', 15, '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":1,\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":\"1\",\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-05 09:57:13', '2025-07-05 09:57:13'),
(8, 15, 'Usuario Admin', 'crear', 'Usuario', 22, NULL, '{\"usuario\":\"Hiavert-MU\",\"nombres\":\"Hiavert Yohad\",\"apellidos\":\"Maldonado Ucles\",\"email\":\"ucleshiaverth@gmail.com\",\"identidad\":\"0801200015479\",\"estado\":\"1\",\"updated_at\":\"2025-07-05T03:59:52.000000Z\",\"created_at\":\"2025-07-05T03:59:52.000000Z\",\"id_usuario\":22}', '127.0.0.1', '2025-07-05 10:00:01', '2025-07-05 10:00:01'),
(9, 15, 'Usuario Admin', 'crear', 'Usuario', 23, NULL, '{\"usuario\":\"papazombi-Z\",\"nombres\":\"papazombi\",\"apellidos\":\"zombi\",\"email\":\"papazombi771@gmail.com\",\"identidad\":\"090910101011\",\"estado\":\"1\",\"updated_at\":\"2025-07-05T04:39:39.000000Z\",\"created_at\":\"2025-07-05T04:39:39.000000Z\",\"id_usuario\":23}', '127.0.0.1', '2025-07-05 10:39:42', '2025-07-05 10:39:42'),
(10, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 15, '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":1,\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":\"1\",\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-05 11:50:53', '2025-07-05 11:50:53'),
(11, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 15, '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":1,\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":\"1\",\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-05 11:51:05', '2025-07-05 11:51:05'),
(12, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 15, '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":1,\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":\"1\",\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-05 12:13:34', '2025-07-05 12:13:34'),
(13, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Rol', 2, '{\"id_rol\":2,\"nombre_rol\":\"Supervisor\",\"descripcion_rol\":\"el que supervisa \",\"estado_rol\":\"1\",\"created_at\":\"2025-06-25T02:25:19.000000Z\",\"updated_at\":\"2025-07-03T14:08:58.000000Z\"}', '{\"id_rol\":2,\"nombre_rol\":\"vendedor\",\"descripcion_rol\":\"el que vende\",\"estado_rol\":\"1\",\"created_at\":\"2025-06-25T02:25:19.000000Z\",\"updated_at\":\"2025-07-07T03:16:13.000000Z\"}', '127.0.0.1', '2025-07-07 09:16:13', '2025-07-07 09:16:13'),
(14, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 23, '{\"id_usuario\":23,\"nombres\":\"papazombi\",\"apellidos\":\"zombi\",\"usuario\":\"papazombi-Z\",\"email\":\"papazombi771@gmail.com\",\"identidad\":\"090910101011\",\"estado\":1,\"created_at\":\"2025-07-05T04:39:39.000000Z\",\"updated_at\":\"2025-07-05T04:40:19.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":23,\"nombres\":\"tati\",\"apellidos\":\"avila\",\"usuario\":\"papazombi-Z\",\"email\":\"papazombi771@gmail.com\",\"identidad\":\"090910101011\",\"estado\":\"1\",\"created_at\":\"2025-07-05T04:39:39.000000Z\",\"updated_at\":\"2025-07-07T03:16:39.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-07 09:16:39', '2025-07-07 09:16:39'),
(15, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 23, '{\"id_usuario\":23,\"nombres\":\"tati\",\"apellidos\":\"avila\",\"usuario\":\"papazombi-Z\",\"email\":\"papazombi771@gmail.com\",\"identidad\":\"090910101011\",\"estado\":1,\"created_at\":\"2025-07-05T04:39:39.000000Z\",\"updated_at\":\"2025-07-07T03:16:39.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":23,\"nombres\":\"tati\",\"apellidos\":\"avila\",\"usuario\":\"papazombi-Z\",\"email\":\"papazombi771@gmail.com\",\"identidad\":\"090910101011\",\"estado\":\"1\",\"created_at\":\"2025-07-05T04:39:39.000000Z\",\"updated_at\":\"2025-07-07T03:16:39.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-07 09:16:51', '2025-07-07 09:16:51'),
(16, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 2, '[{\"id_acceso\":46,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-06-26T04:41:32.000000Z\",\"updated_at\":\"2025-07-01T19:09:47.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":47,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-06-26T04:41:32.000000Z\",\"updated_at\":\"2025-07-01T19:09:47.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":48,\"fk_id_rol\":2,\"fk_id_objeto\":5,\"created_at\":\"2025-06-26T04:41:32.000000Z\",\"updated_at\":\"2025-07-01T19:09:47.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":5,\"nombre_objeto\":\"TareasDocumentales\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de tareas documentales\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '[{\"id_acceso\":113,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T03:18:21.000000Z\",\"updated_at\":\"2025-07-07T03:18:21.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '127.0.0.1', '2025-07-07 09:18:21', '2025-07-07 09:18:21'),
(17, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 2, '[{\"id_acceso\":113,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T03:18:21.000000Z\",\"updated_at\":\"2025-07-07T03:18:21.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '[{\"id_acceso\":114,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T03:18:41.000000Z\",\"updated_at\":\"2025-07-07T03:18:41.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":115,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T03:18:41.000000Z\",\"updated_at\":\"2025-07-07T03:18:41.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '127.0.0.1', '2025-07-07 09:18:41', '2025-07-07 09:18:41'),
(18, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 2, '[{\"id_acceso\":114,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T03:18:41.000000Z\",\"updated_at\":\"2025-07-07T03:18:41.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":115,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T03:18:41.000000Z\",\"updated_at\":\"2025-07-07T03:18:41.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '[{\"id_acceso\":116,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T06:54:44.000000Z\",\"updated_at\":\"2025-07-07T06:54:44.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":117,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T06:54:44.000000Z\",\"updated_at\":\"2025-07-07T06:54:44.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":118,\"fk_id_rol\":2,\"fk_id_objeto\":12,\"created_at\":\"2025-07-07T06:54:44.000000Z\",\"updated_at\":\"2025-07-07T06:54:44.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":12,\"nombre_objeto\":\"GestionAcuses\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gestion de acuses de recibo\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T00:53:28.000000Z\",\"updated_at\":\"2025-07-07T00:53:28.000000Z\"}}]', '127.0.0.1', '2025-07-07 12:54:44', '2025-07-07 12:54:44'),
(19, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 2, '[{\"id_acceso\":116,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T06:54:44.000000Z\",\"updated_at\":\"2025-07-07T06:54:44.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":117,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T06:54:44.000000Z\",\"updated_at\":\"2025-07-07T06:54:44.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":118,\"fk_id_rol\":2,\"fk_id_objeto\":12,\"created_at\":\"2025-07-07T06:54:44.000000Z\",\"updated_at\":\"2025-07-07T06:54:44.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":12,\"nombre_objeto\":\"GestionAcuses\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gestion de acuses de recibo\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T00:53:28.000000Z\",\"updated_at\":\"2025-07-07T00:53:28.000000Z\"}}]', '[{\"id_acceso\":119,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T06:59:48.000000Z\",\"updated_at\":\"2025-07-07T06:59:48.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":120,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T06:59:48.000000Z\",\"updated_at\":\"2025-07-07T06:59:48.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":121,\"fk_id_rol\":2,\"fk_id_objeto\":12,\"created_at\":\"2025-07-07T06:59:48.000000Z\",\"updated_at\":\"2025-07-07T06:59:48.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":12,\"nombre_objeto\":\"GestionAcuses\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gestion de acuses de recibo\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T00:53:28.000000Z\",\"updated_at\":\"2025-07-07T00:53:28.000000Z\"}}]', '127.0.0.1', '2025-07-07 12:59:48', '2025-07-07 12:59:48'),
(20, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 2, '[{\"id_acceso\":119,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T06:59:48.000000Z\",\"updated_at\":\"2025-07-07T06:59:48.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":120,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T06:59:48.000000Z\",\"updated_at\":\"2025-07-07T06:59:48.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":121,\"fk_id_rol\":2,\"fk_id_objeto\":12,\"created_at\":\"2025-07-07T06:59:48.000000Z\",\"updated_at\":\"2025-07-07T06:59:48.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":12,\"nombre_objeto\":\"GestionAcuses\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gestion de acuses de recibo\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T00:53:28.000000Z\",\"updated_at\":\"2025-07-07T00:53:28.000000Z\"}}]', '[{\"id_acceso\":122,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T07:31:12.000000Z\",\"updated_at\":\"2025-07-07T07:31:12.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":123,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T07:31:12.000000Z\",\"updated_at\":\"2025-07-07T07:31:12.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '127.0.0.1', '2025-07-07 13:31:12', '2025-07-07 13:31:12'),
(21, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 2, '[{\"id_acceso\":122,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T07:31:12.000000Z\",\"updated_at\":\"2025-07-07T07:31:12.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":123,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T07:31:12.000000Z\",\"updated_at\":\"2025-07-07T07:31:12.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '[{\"id_acceso\":124,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T07:32:03.000000Z\",\"updated_at\":\"2025-07-07T07:32:03.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":125,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T07:32:03.000000Z\",\"updated_at\":\"2025-07-07T07:32:03.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":126,\"fk_id_rol\":2,\"fk_id_objeto\":12,\"created_at\":\"2025-07-07T07:32:03.000000Z\",\"updated_at\":\"2025-07-07T07:32:03.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":12,\"nombre_objeto\":\"GestionAcuses\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gestion de acuses de recibo\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T00:53:28.000000Z\",\"updated_at\":\"2025-07-07T00:53:28.000000Z\"}}]', '127.0.0.1', '2025-07-07 13:32:03', '2025-07-07 13:32:03'),
(22, 15, 'Usuario Admin', 'editar', 'Usuario', 15, '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":1,\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":\"1\",\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-07 13:48:41', '2025-07-07 13:48:41'),
(23, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 2, '[{\"id_acceso\":124,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T07:32:03.000000Z\",\"updated_at\":\"2025-07-07T07:32:03.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":125,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T07:32:03.000000Z\",\"updated_at\":\"2025-07-07T07:32:03.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":126,\"fk_id_rol\":2,\"fk_id_objeto\":12,\"created_at\":\"2025-07-07T07:32:03.000000Z\",\"updated_at\":\"2025-07-07T07:32:03.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":12,\"nombre_objeto\":\"GestionAcuses\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gestion de acuses de recibo\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T00:53:28.000000Z\",\"updated_at\":\"2025-07-07T00:53:28.000000Z\"}}]', '[{\"id_acceso\":127,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T07:53:00.000000Z\",\"updated_at\":\"2025-07-07T07:53:00.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":128,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T07:53:00.000000Z\",\"updated_at\":\"2025-07-07T07:53:00.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":129,\"fk_id_rol\":2,\"fk_id_objeto\":6,\"created_at\":\"2025-07-07T07:53:00.000000Z\",\"updated_at\":\"2025-07-07T07:53:00.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":6,\"nombre_objeto\":\"TareasTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de tareas de tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":130,\"fk_id_rol\":2,\"fk_id_objeto\":12,\"created_at\":\"2025-07-07T07:53:00.000000Z\",\"updated_at\":\"2025-07-07T07:53:00.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":12,\"nombre_objeto\":\"GestionAcuses\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gestion de acuses de recibo\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T00:53:28.000000Z\",\"updated_at\":\"2025-07-07T00:53:28.000000Z\"}}]', '127.0.0.1', '2025-07-07 13:53:00', '2025-07-07 13:53:00'),
(24, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 2, '[{\"id_acceso\":127,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T07:53:00.000000Z\",\"updated_at\":\"2025-07-07T07:53:00.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":128,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T07:53:00.000000Z\",\"updated_at\":\"2025-07-07T07:53:00.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":130,\"fk_id_rol\":2,\"fk_id_objeto\":12,\"created_at\":\"2025-07-07T07:53:00.000000Z\",\"updated_at\":\"2025-07-07T07:53:00.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":12,\"nombre_objeto\":\"GestionAcuses\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gestion de acuses de recibo\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T00:53:28.000000Z\",\"updated_at\":\"2025-07-07T00:53:28.000000Z\"}}]', '[{\"id_acceso\":131,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T08:14:43.000000Z\",\"updated_at\":\"2025-07-07T08:14:43.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":132,\"fk_id_rol\":2,\"fk_id_objeto\":13,\"created_at\":\"2025-07-07T08:14:43.000000Z\",\"updated_at\":\"2025-07-07T08:14:43.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":13,\"nombre_objeto\":\"GestionTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n Documental de Tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T01:59:18.000000Z\",\"updated_at\":\"2025-07-07T01:59:18.000000Z\"}}]', '127.0.0.1', '2025-07-07 14:14:43', '2025-07-07 14:14:43'),
(25, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 2, '[{\"id_acceso\":131,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T08:14:43.000000Z\",\"updated_at\":\"2025-07-07T08:14:43.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":132,\"fk_id_rol\":2,\"fk_id_objeto\":13,\"created_at\":\"2025-07-07T08:14:43.000000Z\",\"updated_at\":\"2025-07-07T08:14:43.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":13,\"nombre_objeto\":\"GestionTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n Documental de Tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T01:59:18.000000Z\",\"updated_at\":\"2025-07-07T01:59:18.000000Z\"}}]', '[{\"id_acceso\":133,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T08:15:50.000000Z\",\"updated_at\":\"2025-07-07T08:15:50.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '127.0.0.1', '2025-07-07 14:15:50', '2025-07-07 14:15:50'),
(26, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 2, '[{\"id_acceso\":133,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T08:15:50.000000Z\",\"updated_at\":\"2025-07-07T08:15:50.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '[{\"id_acceso\":134,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T08:16:35.000000Z\",\"updated_at\":\"2025-07-07T08:16:35.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":135,\"fk_id_rol\":2,\"fk_id_objeto\":13,\"created_at\":\"2025-07-07T08:16:35.000000Z\",\"updated_at\":\"2025-07-07T08:16:35.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":13,\"nombre_objeto\":\"GestionTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n Documental de Tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T01:59:18.000000Z\",\"updated_at\":\"2025-07-07T01:59:18.000000Z\"}}]', '127.0.0.1', '2025-07-07 14:16:35', '2025-07-07 14:16:35'),
(27, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 2, '[{\"id_acceso\":134,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T08:16:35.000000Z\",\"updated_at\":\"2025-07-07T08:16:35.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":135,\"fk_id_rol\":2,\"fk_id_objeto\":13,\"created_at\":\"2025-07-07T08:16:35.000000Z\",\"updated_at\":\"2025-07-07T08:16:35.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":13,\"nombre_objeto\":\"GestionTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n Documental de Tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T01:59:18.000000Z\",\"updated_at\":\"2025-07-07T01:59:18.000000Z\"}}]', '[{\"id_acceso\":136,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T08:44:48.000000Z\",\"updated_at\":\"2025-07-07T08:44:48.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":137,\"fk_id_rol\":2,\"fk_id_objeto\":13,\"created_at\":\"2025-07-07T08:44:48.000000Z\",\"updated_at\":\"2025-07-07T08:44:48.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":13,\"nombre_objeto\":\"GestionTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n Documental de Tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T01:59:18.000000Z\",\"updated_at\":\"2025-07-07T01:59:18.000000Z\"}}]', '127.0.0.1', '2025-07-07 14:44:48', '2025-07-07 14:44:48'),
(28, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 2, '[{\"id_acceso\":136,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T08:44:48.000000Z\",\"updated_at\":\"2025-07-07T08:44:48.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":137,\"fk_id_rol\":2,\"fk_id_objeto\":13,\"created_at\":\"2025-07-07T08:44:48.000000Z\",\"updated_at\":\"2025-07-07T08:44:48.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":13,\"nombre_objeto\":\"GestionTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n Documental de Tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T01:59:18.000000Z\",\"updated_at\":\"2025-07-07T01:59:18.000000Z\"}}]', '[{\"id_acceso\":138,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T09:03:07.000000Z\",\"updated_at\":\"2025-07-07T09:03:07.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":139,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T09:03:07.000000Z\",\"updated_at\":\"2025-07-07T09:03:07.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":140,\"fk_id_rol\":2,\"fk_id_objeto\":13,\"created_at\":\"2025-07-07T09:03:07.000000Z\",\"updated_at\":\"2025-07-07T09:03:07.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":13,\"nombre_objeto\":\"GestionTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n Documental de Tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T01:59:18.000000Z\",\"updated_at\":\"2025-07-07T01:59:18.000000Z\"}}]', '127.0.0.1', '2025-07-07 15:03:07', '2025-07-07 15:03:07');
INSERT INTO `bitacoras` (`id`, `user_id`, `usuario_nombre`, `accion`, `modulo`, `registro_id`, `datos_antes`, `datos_despues`, `ip`, `created_at`, `updated_at`) VALUES
(29, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 2, '[{\"id_acceso\":138,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T09:03:07.000000Z\",\"updated_at\":\"2025-07-07T09:03:07.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":139,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T09:03:07.000000Z\",\"updated_at\":\"2025-07-07T09:03:07.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":140,\"fk_id_rol\":2,\"fk_id_objeto\":13,\"created_at\":\"2025-07-07T09:03:07.000000Z\",\"updated_at\":\"2025-07-07T09:03:07.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":13,\"nombre_objeto\":\"GestionTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n Documental de Tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T01:59:18.000000Z\",\"updated_at\":\"2025-07-07T01:59:18.000000Z\"}}]', '[{\"id_acceso\":141,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T09:05:13.000000Z\",\"updated_at\":\"2025-07-07T09:05:13.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":142,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T09:05:13.000000Z\",\"updated_at\":\"2025-07-07T09:05:13.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":143,\"fk_id_rol\":2,\"fk_id_objeto\":13,\"created_at\":\"2025-07-07T09:05:13.000000Z\",\"updated_at\":\"2025-07-07T09:05:13.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":13,\"nombre_objeto\":\"GestionTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n Documental de Tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T01:59:18.000000Z\",\"updated_at\":\"2025-07-07T01:59:18.000000Z\"}}]', '127.0.0.1', '2025-07-07 15:05:13', '2025-07-07 15:05:13'),
(30, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 2, '[{\"id_acceso\":141,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T09:05:13.000000Z\",\"updated_at\":\"2025-07-07T09:05:13.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":142,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T09:05:13.000000Z\",\"updated_at\":\"2025-07-07T09:05:13.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":143,\"fk_id_rol\":2,\"fk_id_objeto\":13,\"created_at\":\"2025-07-07T09:05:13.000000Z\",\"updated_at\":\"2025-07-07T09:05:13.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":13,\"nombre_objeto\":\"GestionTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n Documental de Tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T01:59:18.000000Z\",\"updated_at\":\"2025-07-07T01:59:18.000000Z\"}}]', '[{\"id_acceso\":144,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T09:40:37.000000Z\",\"updated_at\":\"2025-07-07T09:40:37.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":145,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T09:40:37.000000Z\",\"updated_at\":\"2025-07-07T09:40:37.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":146,\"fk_id_rol\":2,\"fk_id_objeto\":12,\"created_at\":\"2025-07-07T09:40:37.000000Z\",\"updated_at\":\"2025-07-07T09:40:37.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":12,\"nombre_objeto\":\"GestionAcuses\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gestion de acuses de recibo\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T00:53:28.000000Z\",\"updated_at\":\"2025-07-07T00:53:28.000000Z\"}},{\"id_acceso\":147,\"fk_id_rol\":2,\"fk_id_objeto\":13,\"created_at\":\"2025-07-07T09:40:37.000000Z\",\"updated_at\":\"2025-07-07T09:40:37.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":13,\"nombre_objeto\":\"GestionTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n Documental de Tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T01:59:18.000000Z\",\"updated_at\":\"2025-07-07T01:59:18.000000Z\"}}]', '127.0.0.1', '2025-07-07 15:40:37', '2025-07-07 15:40:37'),
(31, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 2, '[{\"id_acceso\":144,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T09:40:37.000000Z\",\"updated_at\":\"2025-07-07T09:40:37.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":145,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T09:40:37.000000Z\",\"updated_at\":\"2025-07-07T09:40:37.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":146,\"fk_id_rol\":2,\"fk_id_objeto\":12,\"created_at\":\"2025-07-07T09:40:37.000000Z\",\"updated_at\":\"2025-07-07T09:40:37.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":12,\"nombre_objeto\":\"GestionAcuses\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gestion de acuses de recibo\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T00:53:28.000000Z\",\"updated_at\":\"2025-07-07T00:53:28.000000Z\"}},{\"id_acceso\":147,\"fk_id_rol\":2,\"fk_id_objeto\":13,\"created_at\":\"2025-07-07T09:40:37.000000Z\",\"updated_at\":\"2025-07-07T09:40:37.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":13,\"nombre_objeto\":\"GestionTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n Documental de Tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T01:59:18.000000Z\",\"updated_at\":\"2025-07-07T01:59:18.000000Z\"}}]', '[{\"id_acceso\":148,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T09:51:39.000000Z\",\"updated_at\":\"2025-07-07T09:51:39.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":149,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T09:51:39.000000Z\",\"updated_at\":\"2025-07-07T09:51:39.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":150,\"fk_id_rol\":2,\"fk_id_objeto\":13,\"created_at\":\"2025-07-07T09:51:39.000000Z\",\"updated_at\":\"2025-07-07T09:51:39.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":13,\"nombre_objeto\":\"GestionTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n Documental de Tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T01:59:18.000000Z\",\"updated_at\":\"2025-07-07T01:59:18.000000Z\"}}]', '127.0.0.1', '2025-07-07 15:51:39', '2025-07-07 15:51:39'),
(32, 22, 'Hiavert Yohad Maldonado Ucles', 'crear', 'Rol', 5, NULL, '{\"nombre_rol\":\"docente\",\"descripcion_rol\":\"docentar\",\"estado_rol\":\"1\",\"updated_at\":\"2025-07-07T19:40:48.000000Z\",\"created_at\":\"2025-07-07T19:40:48.000000Z\",\"id_rol\":5}', '127.0.0.1', '2025-07-08 01:40:48', '2025-07-08 01:40:48'),
(33, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 23, '{\"id_usuario\":23,\"nombres\":\"tati\",\"apellidos\":\"avila\",\"usuario\":\"papazombi-Z\",\"email\":\"papazombi771@gmail.com\",\"identidad\":\"090910101011\",\"estado\":1,\"created_at\":\"2025-07-05T04:39:39.000000Z\",\"updated_at\":\"2025-07-07T03:16:39.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":23,\"nombres\":\"tati\",\"apellidos\":\"avila\",\"usuario\":\"papazombi-Z\",\"email\":\"papazombi771@gmail.com\",\"identidad\":\"090910101011\",\"estado\":\"1\",\"created_at\":\"2025-07-05T04:39:39.000000Z\",\"updated_at\":\"2025-07-07T03:16:39.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-08 01:41:08', '2025-07-08 01:41:08'),
(34, 23, 'tati avila', 'editar', 'Usuario', 23, '{\"id_usuario\":23,\"nombres\":\"tati\",\"apellidos\":\"avila\",\"usuario\":\"papazombi-Z\",\"email\":\"papazombi771@gmail.com\",\"identidad\":\"090910101011\",\"estado\":1,\"created_at\":\"2025-07-05T04:39:39.000000Z\",\"updated_at\":\"2025-07-07T03:16:39.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":23,\"nombres\":\"tati\",\"apellidos\":\"avila\",\"usuario\":\"papazombi-Z\",\"email\":\"papazombi771@gmail.com\",\"identidad\":\"090910101011\",\"estado\":\"1\",\"created_at\":\"2025-07-05T04:39:39.000000Z\",\"updated_at\":\"2025-07-07T03:16:39.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-08 02:11:37', '2025-07-08 02:11:37'),
(35, 22, 'Hiavert Yohad Maldonado Ucles', 'crear', 'Tarea', 17, NULL, '{\"nombre\":\"imformme\",\"descripcion\":\"realizar informe\",\"fk_id_usuario_asignado\":\"15\",\"fk_id_usuario_creador\":\"22\",\"estado\":\"En Proceso\",\"fecha_creacion\":\"2025-07-07\",\"fecha_vencimiento\":\"2025-07-08\",\"updated_at\":\"2025-07-07T20:22:08.000000Z\",\"created_at\":\"2025-07-07T20:22:08.000000Z\",\"id_tarea\":17}', '127.0.0.1', '2025-07-08 02:22:08', '2025-07-08 02:22:08'),
(36, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 15, '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":1,\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":\"1\",\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-08 02:23:46', '2025-07-08 02:23:46'),
(37, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 5, '[]', '[{\"id_acceso\":151,\"fk_id_rol\":5,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T21:50:21.000000Z\",\"updated_at\":\"2025-07-07T21:50:21.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":152,\"fk_id_rol\":5,\"fk_id_objeto\":11,\"created_at\":\"2025-07-07T21:50:21.000000Z\",\"updated_at\":\"2025-07-07T21:50:21.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":11,\"nombre_objeto\":\"Bitacora\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Vista general de todos los cambios que se realizan.\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T10:16:01.000000Z\",\"updated_at\":\"2025-07-01T21:15:49.000000Z\"}}]', '127.0.0.1', '2025-07-08 03:50:21', '2025-07-08 03:50:21'),
(38, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 23, '{\"id_usuario\":23,\"nombres\":\"tati\",\"apellidos\":\"avila\",\"usuario\":\"papazombi-Z\",\"email\":\"papazombi771@gmail.com\",\"identidad\":\"090910101011\",\"estado\":1,\"created_at\":\"2025-07-05T04:39:39.000000Z\",\"updated_at\":\"2025-07-07T03:16:39.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":23,\"nombres\":\"tati\",\"apellidos\":\"avila\",\"usuario\":\"papazombi-Z\",\"email\":\"papazombi771@gmail.com\",\"identidad\":\"090910101011\",\"estado\":\"1\",\"created_at\":\"2025-07-05T04:39:39.000000Z\",\"updated_at\":\"2025-07-07T03:16:39.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-08 03:50:35', '2025-07-08 03:50:35'),
(39, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 5, '[{\"id_acceso\":151,\"fk_id_rol\":5,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T21:50:21.000000Z\",\"updated_at\":\"2025-07-07T21:50:21.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":152,\"fk_id_rol\":5,\"fk_id_objeto\":11,\"created_at\":\"2025-07-07T21:50:21.000000Z\",\"updated_at\":\"2025-07-07T21:50:21.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":11,\"nombre_objeto\":\"Bitacora\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Vista general de todos los cambios que se realizan.\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T10:16:01.000000Z\",\"updated_at\":\"2025-07-01T21:15:49.000000Z\"}}]', '[{\"id_acceso\":153,\"fk_id_rol\":5,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T21:51:52.000000Z\",\"updated_at\":\"2025-07-07T21:51:52.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":154,\"fk_id_rol\":5,\"fk_id_objeto\":7,\"created_at\":\"2025-07-07T21:51:52.000000Z\",\"updated_at\":\"2025-07-07T21:51:52.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":7,\"nombre_objeto\":\"Usuarios\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de usuarios\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":155,\"fk_id_rol\":5,\"fk_id_objeto\":11,\"created_at\":\"2025-07-07T21:51:52.000000Z\",\"updated_at\":\"2025-07-07T21:51:52.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":11,\"nombre_objeto\":\"Bitacora\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Vista general de todos los cambios que se realizan.\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T10:16:01.000000Z\",\"updated_at\":\"2025-07-01T21:15:49.000000Z\"}}]', '127.0.0.1', '2025-07-08 03:51:52', '2025-07-08 03:51:52'),
(40, 22, 'Hiavert Yohad Maldonado Ucles', 'eliminar', 'Usuario', 23, '{\"id_usuario\":23,\"nombres\":\"tati\",\"apellidos\":\"avila\",\"usuario\":\"papazombi-Z\",\"email\":\"papazombi771@gmail.com\",\"identidad\":\"090910101011\",\"estado\":1,\"created_at\":\"2025-07-05T04:39:39.000000Z\",\"updated_at\":\"2025-07-07T03:16:39.000000Z\",\"deleted_at\":null,\"usr_add\":null}', NULL, '127.0.0.1', '2025-07-08 04:07:38', '2025-07-08 04:07:38'),
(41, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 5, '[{\"id_acceso\":153,\"fk_id_rol\":5,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T21:51:52.000000Z\",\"updated_at\":\"2025-07-07T21:51:52.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":154,\"fk_id_rol\":5,\"fk_id_objeto\":7,\"created_at\":\"2025-07-07T21:51:52.000000Z\",\"updated_at\":\"2025-07-07T21:51:52.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":7,\"nombre_objeto\":\"Usuarios\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de usuarios\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":155,\"fk_id_rol\":5,\"fk_id_objeto\":11,\"created_at\":\"2025-07-07T21:51:52.000000Z\",\"updated_at\":\"2025-07-07T21:51:52.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":11,\"nombre_objeto\":\"Bitacora\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Vista general de todos los cambios que se realizan.\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T10:16:01.000000Z\",\"updated_at\":\"2025-07-01T21:15:49.000000Z\"}}]', '[{\"id_acceso\":156,\"fk_id_rol\":5,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T22:30:34.000000Z\",\"updated_at\":\"2025-07-07T22:30:34.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":157,\"fk_id_rol\":5,\"fk_id_objeto\":7,\"created_at\":\"2025-07-07T22:30:34.000000Z\",\"updated_at\":\"2025-07-07T22:30:34.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":7,\"nombre_objeto\":\"Usuarios\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de usuarios\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":158,\"fk_id_rol\":5,\"fk_id_objeto\":11,\"created_at\":\"2025-07-07T22:30:34.000000Z\",\"updated_at\":\"2025-07-07T22:30:34.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":11,\"nombre_objeto\":\"Bitacora\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Vista general de todos los cambios que se realizan.\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T10:16:01.000000Z\",\"updated_at\":\"2025-07-01T21:15:49.000000Z\"}}]', '127.0.0.1', '2025-07-08 04:30:34', '2025-07-08 04:30:34'),
(42, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 15, '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":1,\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":\"1\",\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-08 04:31:19', '2025-07-08 04:31:19'),
(43, 22, 'Hiavert Yohad Maldonado Ucles', 'crear', 'Tarea', 18, NULL, '{\"nombre\":\"curriculum\",\"descripcion\":\"ponete vivo a revisar\",\"fk_id_usuario_asignado\":\"20\",\"fk_id_usuario_creador\":\"22\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-08\",\"fecha_vencimiento\":\"2025-07-11\",\"updated_at\":\"2025-07-08T00:19:57.000000Z\",\"created_at\":\"2025-07-08T00:19:57.000000Z\",\"id_tarea\":18}', '127.0.0.1', '2025-07-08 06:19:57', '2025-07-08 06:19:57'),
(44, 22, 'Hiavert Yohad Maldonado Ucles', 'crear', 'Tarea', 19, NULL, '{\"nombre\":\"curriculum\",\"descripcion\":\"ponete vivo a revisar\",\"fk_id_usuario_asignado\":\"20\",\"fk_id_usuario_creador\":\"22\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-08\",\"fecha_vencimiento\":\"2025-07-11\",\"updated_at\":\"2025-07-08T00:20:17.000000Z\",\"created_at\":\"2025-07-08T00:20:17.000000Z\",\"id_tarea\":19}', '127.0.0.1', '2025-07-08 06:20:17', '2025-07-08 06:20:17'),
(45, 22, 'Hiavert Yohad Maldonado Ucles', 'cargar_documento', 'Documento', 6, NULL, '{\"nombre_documento\":\"Captura de pantalla 2024-11-25 222410.png\",\"descripcion\":null,\"ruta_archivo\":\"tareas_documentos\\/fBK6as1Jzd2zqNPImMhF1qFjK0KXiITb4t6gTUBa.png\",\"fecha_subida\":\"2025-07-08T00:20:48.973450Z\",\"fk_id_usuario\":22,\"fk_id_tipo\":\"1\",\"updated_at\":\"2025-07-08T00:20:48.000000Z\",\"created_at\":\"2025-07-08T00:20:48.000000Z\",\"id_documento\":6}', '127.0.0.1', '2025-07-08 06:20:49', '2025-07-08 06:20:49'),
(46, 22, 'Hiavert Yohad Maldonado Ucles', 'asociar_documento', 'Tarea', 18, NULL, '{\"id_documento\":6}', '127.0.0.1', '2025-07-08 06:20:49', '2025-07-08 06:20:49'),
(47, 22, 'Hiavert Yohad Maldonado Ucles', 'cargar_documento', 'Documento', 7, NULL, '{\"nombre_documento\":\"Captura de pantalla 2024-12-04 213434.png\",\"descripcion\":null,\"ruta_archivo\":\"tareas_documentos\\/vDY35MX7T5sosZzoe0XyabctYZ0ji1g4YOxbNd4W.png\",\"fecha_subida\":\"2025-07-08T00:21:10.129459Z\",\"fk_id_usuario\":22,\"fk_id_tipo\":\"1\",\"updated_at\":\"2025-07-08T00:21:10.000000Z\",\"created_at\":\"2025-07-08T00:21:10.000000Z\",\"id_documento\":7}', '127.0.0.1', '2025-07-08 06:21:10', '2025-07-08 06:21:10'),
(48, 22, 'Hiavert Yohad Maldonado Ucles', 'asociar_documento', 'Tarea', 18, NULL, '{\"id_documento\":7}', '127.0.0.1', '2025-07-08 06:21:10', '2025-07-08 06:21:10'),
(49, 22, 'Hiavert Yohad Maldonado Ucles', 'crear', 'Usuario', 24, NULL, '{\"usuario\":\"lester-F\",\"nombres\":\"lester\",\"apellidos\":\"fiallos\",\"email\":\"lfiallos@appteck.com\",\"identidad\":\"080120001547\",\"estado\":\"1\",\"updated_at\":\"2025-07-08T00:27:19.000000Z\",\"created_at\":\"2025-07-08T00:27:19.000000Z\",\"id_usuario\":24}', '127.0.0.1', '2025-07-08 06:27:23', '2025-07-08 06:27:23'),
(50, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 5, '[{\"id_acceso\":156,\"fk_id_rol\":5,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T22:30:34.000000Z\",\"updated_at\":\"2025-07-07T22:30:34.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":157,\"fk_id_rol\":5,\"fk_id_objeto\":7,\"created_at\":\"2025-07-07T22:30:34.000000Z\",\"updated_at\":\"2025-07-07T22:30:34.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":7,\"nombre_objeto\":\"Usuarios\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de usuarios\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":158,\"fk_id_rol\":5,\"fk_id_objeto\":11,\"created_at\":\"2025-07-07T22:30:34.000000Z\",\"updated_at\":\"2025-07-07T22:30:34.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":11,\"nombre_objeto\":\"Bitacora\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Vista general de todos los cambios que se realizan.\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T10:16:01.000000Z\",\"updated_at\":\"2025-07-01T21:15:49.000000Z\"}}]', '[{\"id_acceso\":159,\"fk_id_rol\":5,\"fk_id_objeto\":3,\"created_at\":\"2025-07-08T00:29:35.000000Z\",\"updated_at\":\"2025-07-08T00:29:35.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":160,\"fk_id_rol\":5,\"fk_id_objeto\":4,\"created_at\":\"2025-07-08T00:29:35.000000Z\",\"updated_at\":\"2025-07-08T00:29:35.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '127.0.0.1', '2025-07-08 06:29:35', '2025-07-08 06:29:35'),
(51, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 15, '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":1,\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":\"1\",\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-08 06:30:12', '2025-07-08 06:30:12'),
(52, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 5, '[{\"id_acceso\":159,\"fk_id_rol\":5,\"fk_id_objeto\":3,\"created_at\":\"2025-07-08T00:29:35.000000Z\",\"updated_at\":\"2025-07-08T00:29:35.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":160,\"fk_id_rol\":5,\"fk_id_objeto\":4,\"created_at\":\"2025-07-08T00:29:35.000000Z\",\"updated_at\":\"2025-07-08T00:29:35.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '[{\"id_acceso\":161,\"fk_id_rol\":5,\"fk_id_objeto\":3,\"created_at\":\"2025-07-16T21:34:25.000000Z\",\"updated_at\":\"2025-07-16T21:34:25.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":162,\"fk_id_rol\":5,\"fk_id_objeto\":4,\"created_at\":\"2025-07-16T21:34:25.000000Z\",\"updated_at\":\"2025-07-16T21:34:25.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":163,\"fk_id_rol\":5,\"fk_id_objeto\":14,\"created_at\":\"2025-07-16T21:34:25.000000Z\",\"updated_at\":\"2025-07-16T21:34:25.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":14,\"nombre_objeto\":\"GestorRendimiento\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Graficos de terna y tareas\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-16T15:32:41.000000Z\",\"updated_at\":\"2025-07-16T15:32:41.000000Z\"}}]', '127.0.0.1', '2025-07-17 03:34:25', '2025-07-17 03:34:25'),
(53, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Tarea', 17, '{\"id_tarea\":17,\"fk_id_usuario_asignado\":15,\"fk_id_usuario_creador\":22,\"nombre\":\"imformme\",\"descripcion\":\"realizar informe\",\"estado\":\"En Proceso\",\"fecha_creacion\":\"2025-07-07\",\"fecha_vencimiento\":\"2025-07-08\",\"created_at\":\"2025-07-07T20:22:08.000000Z\",\"updated_at\":\"2025-07-07T20:22:08.000000Z\",\"deleted_at\":null}', '{\"id_tarea\":17,\"fk_id_usuario_asignado\":\"15\",\"fk_id_usuario_creador\":\"22\",\"nombre\":\"imformme\",\"descripcion\":\"realizar informe\",\"estado\":\"Completada\",\"fecha_creacion\":\"2025-07-07\",\"fecha_vencimiento\":null,\"created_at\":\"2025-07-07T20:22:08.000000Z\",\"updated_at\":\"2025-07-16T22:10:49.000000Z\",\"deleted_at\":null}', '127.0.0.1', '2025-07-17 04:10:49', '2025-07-17 04:10:49'),
(54, 22, 'Hiavert Yohad Maldonado Ucles', 'cambiar_estado', 'Tarea', 17, '{\"estado\":\"En Proceso\"}', '{\"estado\":\"Completada\"}', '127.0.0.1', '2025-07-17 04:10:49', '2025-07-17 04:10:49'),
(55, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Tarea', 19, '{\"id_tarea\":19,\"fk_id_usuario_asignado\":20,\"fk_id_usuario_creador\":22,\"nombre\":\"curriculum\",\"descripcion\":\"ponete vivo a revisar\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-08\",\"fecha_vencimiento\":\"2025-07-11\",\"created_at\":\"2025-07-08T00:20:17.000000Z\",\"updated_at\":\"2025-07-08T00:20:17.000000Z\",\"deleted_at\":null}', '{\"id_tarea\":19,\"fk_id_usuario_asignado\":\"20\",\"fk_id_usuario_creador\":\"22\",\"nombre\":\"curriculum\",\"descripcion\":\"ponete vivo a revisar\",\"estado\":\"Rechazada\",\"fecha_creacion\":\"2025-07-08\",\"fecha_vencimiento\":null,\"created_at\":\"2025-07-08T00:20:17.000000Z\",\"updated_at\":\"2025-07-16T22:25:27.000000Z\",\"deleted_at\":null}', '127.0.0.1', '2025-07-17 04:25:27', '2025-07-17 04:25:27'),
(56, 22, 'Hiavert Yohad Maldonado Ucles', 'cambiar_estado', 'Tarea', 19, '{\"estado\":\"Pendiente\"}', '{\"estado\":\"Rechazada\"}', '127.0.0.1', '2025-07-17 04:25:27', '2025-07-17 04:25:27'),
(57, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Tarea', 19, '{\"id_tarea\":19,\"fk_id_usuario_asignado\":20,\"fk_id_usuario_creador\":22,\"nombre\":\"curriculum\",\"descripcion\":\"ponete vivo a revisar\",\"estado\":\"Rechazada\",\"fecha_creacion\":\"2025-07-08\",\"fecha_vencimiento\":null,\"created_at\":\"2025-07-08T00:20:17.000000Z\",\"updated_at\":\"2025-07-16T22:25:27.000000Z\",\"deleted_at\":null}', '{\"id_tarea\":19,\"fk_id_usuario_asignado\":\"20\",\"fk_id_usuario_creador\":\"22\",\"nombre\":\"curriculum\",\"descripcion\":\"ponete vivo a revisar\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-08\",\"fecha_vencimiento\":null,\"created_at\":\"2025-07-08T00:20:17.000000Z\",\"updated_at\":\"2025-07-16T22:26:09.000000Z\",\"deleted_at\":null}', '127.0.0.1', '2025-07-17 04:26:09', '2025-07-17 04:26:09'),
(58, 22, 'Hiavert Yohad Maldonado Ucles', 'cambiar_estado', 'Tarea', 19, '{\"estado\":\"Rechazada\"}', '{\"estado\":\"Pendiente\"}', '127.0.0.1', '2025-07-17 04:26:09', '2025-07-17 04:26:09'),
(59, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Tarea', 18, '{\"id_tarea\":18,\"fk_id_usuario_asignado\":20,\"fk_id_usuario_creador\":22,\"nombre\":\"curriculum\",\"descripcion\":\"ponete vivo a revisar\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-08\",\"fecha_vencimiento\":\"2025-07-11\",\"created_at\":\"2025-07-08T00:19:57.000000Z\",\"updated_at\":\"2025-07-08T00:19:57.000000Z\",\"deleted_at\":null}', '{\"id_tarea\":18,\"fk_id_usuario_asignado\":\"20\",\"fk_id_usuario_creador\":\"22\",\"nombre\":\"curriculum\",\"descripcion\":\"ponete vivo a revisar\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-08\",\"fecha_vencimiento\":\"2025-07-14\",\"created_at\":\"2025-07-08T00:19:57.000000Z\",\"updated_at\":\"2025-07-16T22:26:44.000000Z\",\"deleted_at\":null}', '127.0.0.1', '2025-07-17 04:26:44', '2025-07-17 04:26:44'),
(60, 22, 'Hiavert Yohad Maldonado Ucles', 'crear', 'Tarea', 20, NULL, '{\"nombre\":\"imformme\",\"descripcion\":\"jgjggQ\",\"fk_id_usuario_asignado\":\"24\",\"fk_id_usuario_creador\":\"22\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-09\",\"fecha_vencimiento\":\"2025-07-10\",\"updated_at\":\"2025-07-16T22:28:51.000000Z\",\"created_at\":\"2025-07-16T22:28:51.000000Z\",\"id_tarea\":20}', '127.0.0.1', '2025-07-17 04:28:51', '2025-07-17 04:28:51'),
(61, 22, 'Hiavert Yohad Maldonado Ucles', 'crear', 'Tarea', 21, NULL, '{\"nombre\":\"curriculum\",\"descripcion\":\"ioshgiogh\",\"fk_id_usuario_asignado\":\"22\",\"fk_id_usuario_creador\":\"22\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-09\",\"fecha_vencimiento\":\"2025-07-11\",\"updated_at\":\"2025-07-16T22:29:44.000000Z\",\"created_at\":\"2025-07-16T22:29:44.000000Z\",\"id_tarea\":21}', '127.0.0.1', '2025-07-17 04:29:44', '2025-07-17 04:29:44'),
(62, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 5, '[{\"id_acceso\":161,\"fk_id_rol\":5,\"fk_id_objeto\":3,\"created_at\":\"2025-07-16T21:34:25.000000Z\",\"updated_at\":\"2025-07-16T21:34:25.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":162,\"fk_id_rol\":5,\"fk_id_objeto\":4,\"created_at\":\"2025-07-16T21:34:25.000000Z\",\"updated_at\":\"2025-07-16T21:34:25.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":163,\"fk_id_rol\":5,\"fk_id_objeto\":14,\"created_at\":\"2025-07-16T21:34:25.000000Z\",\"updated_at\":\"2025-07-16T21:34:25.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":14,\"nombre_objeto\":\"GestorRendimiento\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Graficos de terna y tareas\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-16T15:32:41.000000Z\",\"updated_at\":\"2025-07-16T15:32:41.000000Z\"}}]', '[{\"id_acceso\":164,\"fk_id_rol\":5,\"fk_id_objeto\":3,\"created_at\":\"2025-07-16T22:32:53.000000Z\",\"updated_at\":\"2025-07-16T22:32:53.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":165,\"fk_id_rol\":5,\"fk_id_objeto\":14,\"created_at\":\"2025-07-16T22:32:53.000000Z\",\"updated_at\":\"2025-07-16T22:32:53.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":14,\"nombre_objeto\":\"GestorRendimiento\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Graficos de terna y tareas\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-16T15:32:41.000000Z\",\"updated_at\":\"2025-07-16T15:32:41.000000Z\"}}]', '127.0.0.1', '2025-07-17 04:32:53', '2025-07-17 04:32:53'),
(63, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 5, '[{\"id_acceso\":164,\"fk_id_rol\":5,\"fk_id_objeto\":3,\"created_at\":\"2025-07-16T22:32:53.000000Z\",\"updated_at\":\"2025-07-16T22:32:53.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":165,\"fk_id_rol\":5,\"fk_id_objeto\":14,\"created_at\":\"2025-07-16T22:32:53.000000Z\",\"updated_at\":\"2025-07-16T22:32:53.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":14,\"nombre_objeto\":\"GestorRendimiento\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Graficos de terna y tareas\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-16T15:32:41.000000Z\",\"updated_at\":\"2025-07-16T15:32:41.000000Z\"}}]', '[{\"id_acceso\":166,\"fk_id_rol\":5,\"fk_id_objeto\":3,\"created_at\":\"2025-07-16T22:34:30.000000Z\",\"updated_at\":\"2025-07-16T22:34:30.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '127.0.0.1', '2025-07-17 04:34:30', '2025-07-17 04:34:30'),
(64, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 5, '[{\"id_acceso\":166,\"fk_id_rol\":5,\"fk_id_objeto\":3,\"created_at\":\"2025-07-16T22:34:30.000000Z\",\"updated_at\":\"2025-07-16T22:34:30.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '[{\"id_acceso\":167,\"fk_id_rol\":5,\"fk_id_objeto\":3,\"created_at\":\"2025-07-16T23:07:24.000000Z\",\"updated_at\":\"2025-07-16T23:07:24.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":168,\"fk_id_rol\":5,\"fk_id_objeto\":5,\"created_at\":\"2025-07-16T23:07:24.000000Z\",\"updated_at\":\"2025-07-16T23:07:24.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":5,\"nombre_objeto\":\"TareasDocumentales\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de tareas documentales\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '127.0.0.1', '2025-07-17 05:07:24', '2025-07-17 05:07:24'),
(65, 22, 'Hiavert Yohad Maldonado Ucles', 'crear', 'Usuario', 25, NULL, '{\"usuario\":\"Hiuvert-M\",\"nombres\":\"Hiuvert\",\"apellidos\":\"Maldonado\",\"email\":\"hiavert.maldonado@unah.hn\",\"identidad\":\"0801198005264\",\"estado\":\"1\",\"updated_at\":\"2025-07-20T05:31:28.000000Z\",\"created_at\":\"2025-07-20T05:31:28.000000Z\",\"id_usuario\":25}', '127.0.0.1', '2025-07-20 11:31:31', '2025-07-20 11:31:31'),
(66, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Tarea', 18, '{\"id_tarea\":18,\"fk_id_usuario_asignado\":20,\"fk_id_usuario_creador\":22,\"nombre\":\"curriculum\",\"descripcion\":\"ponete vivo a revisar\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-08\",\"fecha_vencimiento\":\"2025-07-14\",\"created_at\":\"2025-07-08T00:19:57.000000Z\",\"updated_at\":\"2025-07-16T22:26:44.000000Z\",\"deleted_at\":null}', '{\"id_tarea\":18,\"fk_id_usuario_asignado\":\"20\",\"fk_id_usuario_creador\":\"22\",\"nombre\":\"curriculum\",\"descripcion\":\"ponete vivo a revisar\",\"estado\":\"Completada\",\"fecha_creacion\":\"2025-07-08\",\"fecha_vencimiento\":null,\"created_at\":\"2025-07-08T00:19:57.000000Z\",\"updated_at\":\"2025-07-21T03:05:53.000000Z\",\"deleted_at\":null}', '127.0.0.1', '2025-07-21 09:05:53', '2025-07-21 09:05:53'),
(67, 22, 'Hiavert Yohad Maldonado Ucles', 'cambiar_estado', 'Tarea', 18, '{\"estado\":\"Pendiente\"}', '{\"estado\":\"Completada\"}', '127.0.0.1', '2025-07-21 09:05:53', '2025-07-21 09:05:53'),
(68, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 5, '[{\"id_acceso\":167,\"fk_id_rol\":5,\"fk_id_objeto\":3,\"created_at\":\"2025-07-16T23:07:24.000000Z\",\"updated_at\":\"2025-07-16T23:07:24.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":168,\"fk_id_rol\":5,\"fk_id_objeto\":5,\"created_at\":\"2025-07-16T23:07:24.000000Z\",\"updated_at\":\"2025-07-16T23:07:24.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":5,\"nombre_objeto\":\"TareasDocumentales\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de tareas documentales\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '[{\"id_acceso\":169,\"fk_id_rol\":5,\"fk_id_objeto\":3,\"created_at\":\"2025-07-21T03:09:51.000000Z\",\"updated_at\":\"2025-07-21T03:09:51.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":170,\"fk_id_rol\":5,\"fk_id_objeto\":5,\"created_at\":\"2025-07-21T03:09:51.000000Z\",\"updated_at\":\"2025-07-21T03:09:51.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":5,\"nombre_objeto\":\"TareasDocumentales\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de tareas documentales\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":171,\"fk_id_rol\":5,\"fk_id_objeto\":12,\"created_at\":\"2025-07-21T03:09:51.000000Z\",\"updated_at\":\"2025-07-21T03:09:51.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":12,\"nombre_objeto\":\"GestionAcuses\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gestion de acuses de recibo\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T00:53:28.000000Z\",\"updated_at\":\"2025-07-07T00:53:28.000000Z\"}},{\"id_acceso\":172,\"fk_id_rol\":5,\"fk_id_objeto\":16,\"created_at\":\"2025-07-21T03:09:51.000000Z\",\"updated_at\":\"2025-07-21T03:09:51.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":16,\"nombre_objeto\":\"Perfil\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de perfiles de usuario\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-19T14:19:43.000000Z\",\"updated_at\":\"2025-07-19T14:20:06.000000Z\"}}]', '127.0.0.1', '2025-07-21 09:09:51', '2025-07-21 09:09:51'),
(69, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 15, '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":1,\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":\"1\",\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-21 09:12:36', '2025-07-21 09:12:36');
INSERT INTO `bitacoras` (`id`, `user_id`, `usuario_nombre`, `accion`, `modulo`, `registro_id`, `datos_antes`, `datos_despues`, `ip`, `created_at`, `updated_at`) VALUES
(70, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 2, '[{\"id_acceso\":148,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-07T09:51:39.000000Z\",\"updated_at\":\"2025-07-07T09:51:39.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":149,\"fk_id_rol\":2,\"fk_id_objeto\":4,\"created_at\":\"2025-07-07T09:51:39.000000Z\",\"updated_at\":\"2025-07-07T09:51:39.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":150,\"fk_id_rol\":2,\"fk_id_objeto\":13,\"created_at\":\"2025-07-07T09:51:39.000000Z\",\"updated_at\":\"2025-07-07T09:51:39.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":13,\"nombre_objeto\":\"GestionTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n Documental de Tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T01:59:18.000000Z\",\"updated_at\":\"2025-07-07T01:59:18.000000Z\"}}]', '[{\"id_acceso\":173,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-21T03:13:05.000000Z\",\"updated_at\":\"2025-07-21T03:13:05.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":174,\"fk_id_rol\":2,\"fk_id_objeto\":12,\"created_at\":\"2025-07-21T03:13:05.000000Z\",\"updated_at\":\"2025-07-21T03:13:05.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":12,\"nombre_objeto\":\"GestionAcuses\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gestion de acuses de recibo\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T00:53:28.000000Z\",\"updated_at\":\"2025-07-07T00:53:28.000000Z\"}}]', '127.0.0.1', '2025-07-21 09:13:05', '2025-07-21 09:13:05'),
(71, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 2, '[{\"id_acceso\":173,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-21T03:13:05.000000Z\",\"updated_at\":\"2025-07-21T03:13:05.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":174,\"fk_id_rol\":2,\"fk_id_objeto\":12,\"created_at\":\"2025-07-21T03:13:05.000000Z\",\"updated_at\":\"2025-07-21T03:13:05.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":12,\"nombre_objeto\":\"GestionAcuses\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gestion de acuses de recibo\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T00:53:28.000000Z\",\"updated_at\":\"2025-07-07T00:53:28.000000Z\"}}]', '[{\"id_acceso\":175,\"fk_id_rol\":2,\"fk_id_objeto\":3,\"created_at\":\"2025-07-21T03:31:05.000000Z\",\"updated_at\":\"2025-07-21T03:31:05.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":176,\"fk_id_rol\":2,\"fk_id_objeto\":12,\"created_at\":\"2025-07-21T03:31:05.000000Z\",\"updated_at\":\"2025-07-21T03:31:05.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":12,\"nombre_objeto\":\"GestionAcuses\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gestion de acuses de recibo\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T00:53:28.000000Z\",\"updated_at\":\"2025-07-07T00:53:28.000000Z\"}}]', '127.0.0.1', '2025-07-21 09:31:05', '2025-07-21 09:31:05'),
(72, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 25, '{\"id_usuario\":25,\"nombres\":\"Hiuvert\",\"apellidos\":\"Maldonado\",\"usuario\":\"Hiuvert-M\",\"email\":\"hiavert.maldonado@unah.hn\",\"identidad\":\"0801198005264\",\"estado\":1,\"created_at\":\"2025-07-20T05:31:28.000000Z\",\"updated_at\":\"2025-07-20T05:32:42.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":25,\"nombres\":\"Hiuvert\",\"apellidos\":\"Maldonado\",\"usuario\":\"Hiuvert-M\",\"email\":\"hiavert.maldonado@unah.hn\",\"identidad\":\"0801198005264\",\"estado\":\"1\",\"created_at\":\"2025-07-20T05:31:28.000000Z\",\"updated_at\":\"2025-07-20T05:32:42.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-21 09:42:02', '2025-07-21 09:42:02'),
(73, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Tarea', 19, '{\"id_tarea\":19,\"fk_id_usuario_asignado\":20,\"fk_id_usuario_creador\":22,\"nombre\":\"curriculum\",\"descripcion\":\"ponete vivo a revisar\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-08\",\"fecha_vencimiento\":null,\"created_at\":\"2025-07-08T00:20:17.000000Z\",\"updated_at\":\"2025-07-16T22:26:09.000000Z\",\"deleted_at\":null}', '{\"id_tarea\":19,\"fk_id_usuario_asignado\":\"20\",\"fk_id_usuario_creador\":\"22\",\"nombre\":\"curriculum\",\"descripcion\":\"ponete vivo a revisar\",\"estado\":\"Completada\",\"fecha_creacion\":\"2025-07-08\",\"fecha_vencimiento\":null,\"created_at\":\"2025-07-08T00:20:17.000000Z\",\"updated_at\":\"2025-07-21T04:51:06.000000Z\",\"deleted_at\":null}', '127.0.0.1', '2025-07-21 10:51:06', '2025-07-21 10:51:06'),
(74, 22, 'Hiavert Yohad Maldonado Ucles', 'cambiar_estado', 'Tarea', 19, '{\"estado\":\"Pendiente\"}', '{\"estado\":\"Completada\"}', '127.0.0.1', '2025-07-21 10:51:06', '2025-07-21 10:51:06'),
(75, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Tarea', 20, '{\"id_tarea\":20,\"fk_id_usuario_asignado\":24,\"fk_id_usuario_creador\":22,\"nombre\":\"imformme\",\"descripcion\":\"jgjggQ\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-09\",\"fecha_vencimiento\":\"2025-07-10\",\"created_at\":\"2025-07-16T22:28:51.000000Z\",\"updated_at\":\"2025-07-16T22:28:51.000000Z\",\"deleted_at\":null}', '{\"id_tarea\":20,\"fk_id_usuario_asignado\":\"24\",\"fk_id_usuario_creador\":\"22\",\"nombre\":\"imformme\",\"descripcion\":\"jgjggQ\",\"estado\":\"Completada\",\"fecha_creacion\":\"2025-07-09\",\"fecha_vencimiento\":null,\"created_at\":\"2025-07-16T22:28:51.000000Z\",\"updated_at\":\"2025-07-21T04:51:15.000000Z\",\"deleted_at\":null}', '127.0.0.1', '2025-07-21 10:51:15', '2025-07-21 10:51:15'),
(76, 22, 'Hiavert Yohad Maldonado Ucles', 'cambiar_estado', 'Tarea', 20, '{\"estado\":\"Pendiente\"}', '{\"estado\":\"Completada\"}', '127.0.0.1', '2025-07-21 10:51:15', '2025-07-21 10:51:15'),
(77, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Tarea', 21, '{\"id_tarea\":21,\"fk_id_usuario_asignado\":22,\"fk_id_usuario_creador\":22,\"nombre\":\"curriculum\",\"descripcion\":\"ioshgiogh\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-09\",\"fecha_vencimiento\":\"2025-07-11\",\"created_at\":\"2025-07-16T22:29:44.000000Z\",\"updated_at\":\"2025-07-16T22:29:44.000000Z\",\"deleted_at\":null}', '{\"id_tarea\":21,\"fk_id_usuario_asignado\":\"22\",\"fk_id_usuario_creador\":\"22\",\"nombre\":\"curriculum\",\"descripcion\":\"ioshgiogh\",\"estado\":\"Completada\",\"fecha_creacion\":\"2025-07-09\",\"fecha_vencimiento\":null,\"created_at\":\"2025-07-16T22:29:44.000000Z\",\"updated_at\":\"2025-07-21T04:51:29.000000Z\",\"deleted_at\":null}', '127.0.0.1', '2025-07-21 10:51:29', '2025-07-21 10:51:29'),
(78, 22, 'Hiavert Yohad Maldonado Ucles', 'cambiar_estado', 'Tarea', 21, '{\"estado\":\"Pendiente\"}', '{\"estado\":\"Completada\"}', '127.0.0.1', '2025-07-21 10:51:29', '2025-07-21 10:51:29'),
(79, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 25, '{\"id_usuario\":25,\"nombres\":\"Hiuvert\",\"apellidos\":\"Maldonado\",\"usuario\":\"Hiuvert-M\",\"email\":\"hiavert.maldonado@unah.hn\",\"identidad\":\"0801198005264\",\"estado\":1,\"created_at\":\"2025-07-20T05:31:28.000000Z\",\"updated_at\":\"2025-07-20T05:32:42.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":25,\"nombres\":\"Hiuvert\",\"apellidos\":\"Maldonado\",\"usuario\":\"Hiuvert-M\",\"email\":\"hiavert.maldonado@unah.hn\",\"identidad\":\"0801198005264\",\"estado\":\"1\",\"created_at\":\"2025-07-20T05:31:28.000000Z\",\"updated_at\":\"2025-07-20T05:32:42.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-21 11:10:29', '2025-07-21 11:10:29'),
(80, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 25, '{\"id_usuario\":25,\"nombres\":\"Hiuvert\",\"apellidos\":\"Maldonado\",\"usuario\":\"Hiuvert-M\",\"email\":\"hiavert.maldonado@unah.hn\",\"identidad\":\"0801198005264\",\"estado\":1,\"created_at\":\"2025-07-20T05:31:28.000000Z\",\"updated_at\":\"2025-07-20T05:32:42.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":25,\"nombres\":\"Hiuvert\",\"apellidos\":\"Maldonado\",\"usuario\":\"Hiuvert-M\",\"email\":\"hiavert.maldonado@unah.hn\",\"identidad\":\"0801198005264\",\"estado\":\"1\",\"created_at\":\"2025-07-20T05:31:28.000000Z\",\"updated_at\":\"2025-07-20T05:32:42.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-21 11:24:38', '2025-07-21 11:24:38'),
(81, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 5, '[{\"id_acceso\":169,\"fk_id_rol\":5,\"fk_id_objeto\":3,\"created_at\":\"2025-07-21T03:09:51.000000Z\",\"updated_at\":\"2025-07-21T03:09:51.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":170,\"fk_id_rol\":5,\"fk_id_objeto\":5,\"created_at\":\"2025-07-21T03:09:51.000000Z\",\"updated_at\":\"2025-07-21T03:09:51.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":5,\"nombre_objeto\":\"TareasDocumentales\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de tareas documentales\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":171,\"fk_id_rol\":5,\"fk_id_objeto\":12,\"created_at\":\"2025-07-21T03:09:51.000000Z\",\"updated_at\":\"2025-07-21T03:09:51.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":12,\"nombre_objeto\":\"GestionAcuses\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gestion de acuses de recibo\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T00:53:28.000000Z\",\"updated_at\":\"2025-07-07T00:53:28.000000Z\"}},{\"id_acceso\":172,\"fk_id_rol\":5,\"fk_id_objeto\":16,\"created_at\":\"2025-07-21T03:09:51.000000Z\",\"updated_at\":\"2025-07-21T03:09:51.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":16,\"nombre_objeto\":\"Perfil\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de perfiles de usuario\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-19T14:19:43.000000Z\",\"updated_at\":\"2025-07-19T14:20:06.000000Z\"}}]', '[{\"id_acceso\":177,\"fk_id_rol\":5,\"fk_id_objeto\":3,\"created_at\":\"2025-07-21T05:24:52.000000Z\",\"updated_at\":\"2025-07-21T05:24:52.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":178,\"fk_id_rol\":5,\"fk_id_objeto\":5,\"created_at\":\"2025-07-21T05:24:52.000000Z\",\"updated_at\":\"2025-07-21T05:24:52.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":5,\"nombre_objeto\":\"TareasDocumentales\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de tareas documentales\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":179,\"fk_id_rol\":5,\"fk_id_objeto\":12,\"created_at\":\"2025-07-21T05:24:52.000000Z\",\"updated_at\":\"2025-07-21T05:24:52.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":12,\"nombre_objeto\":\"GestionAcuses\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gestion de acuses de recibo\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T00:53:28.000000Z\",\"updated_at\":\"2025-07-07T00:53:28.000000Z\"}},{\"id_acceso\":180,\"fk_id_rol\":5,\"fk_id_objeto\":16,\"created_at\":\"2025-07-21T05:24:52.000000Z\",\"updated_at\":\"2025-07-21T05:24:52.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":16,\"nombre_objeto\":\"Perfil\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de perfiles de usuario\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-19T14:19:43.000000Z\",\"updated_at\":\"2025-07-19T14:20:06.000000Z\"}}]', '127.0.0.1', '2025-07-21 11:24:52', '2025-07-21 11:24:52'),
(82, 22, 'Hiavert Yohad Maldonado Ucles', 'crear', 'Rol', 6, NULL, '{\"nombre_rol\":\"Asistente de Terna\",\"descripcion_rol\":\"Realiza seguimiento de Pagos terna\",\"estado_rol\":\"1\",\"updated_at\":\"2025-07-21T21:18:37.000000Z\",\"created_at\":\"2025-07-21T21:18:37.000000Z\",\"id_rol\":6}', '127.0.0.1', '2025-07-22 03:18:37', '2025-07-22 03:18:37'),
(83, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 15, '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":1,\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":\"1\",\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-22 03:18:55', '2025-07-22 03:18:55'),
(84, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 6, '[]', '[{\"id_acceso\":181,\"fk_id_rol\":6,\"fk_id_objeto\":3,\"created_at\":\"2025-07-21T21:19:19.000000Z\",\"updated_at\":\"2025-07-21T21:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":182,\"fk_id_rol\":6,\"fk_id_objeto\":4,\"created_at\":\"2025-07-21T21:19:19.000000Z\",\"updated_at\":\"2025-07-21T21:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '127.0.0.1', '2025-07-22 03:19:19', '2025-07-22 03:19:19'),
(85, 22, 'Hiavert Yohad Maldonado Ucles', 'crear', 'Rol', 7, NULL, '{\"nombre_rol\":\"Administrador de Terna\",\"descripcion_rol\":\"Inicia el proceso de pago terna\",\"estado_rol\":\"1\",\"updated_at\":\"2025-07-21T21:21:22.000000Z\",\"created_at\":\"2025-07-21T21:21:22.000000Z\",\"id_rol\":7}', '127.0.0.1', '2025-07-22 03:21:23', '2025-07-22 03:21:23'),
(86, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 7, '[]', '[{\"id_acceso\":183,\"fk_id_rol\":7,\"fk_id_objeto\":3,\"created_at\":\"2025-07-21T21:21:59.000000Z\",\"updated_at\":\"2025-07-21T21:21:59.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":184,\"fk_id_rol\":7,\"fk_id_objeto\":4,\"created_at\":\"2025-07-21T21:21:59.000000Z\",\"updated_at\":\"2025-07-21T21:21:59.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '127.0.0.1', '2025-07-22 03:21:59', '2025-07-22 03:21:59'),
(87, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 25, '{\"id_usuario\":25,\"nombres\":\"Hiuvert\",\"apellidos\":\"Maldonado\",\"usuario\":\"Hiuvert-M\",\"email\":\"hiavert.maldonado@unah.hn\",\"identidad\":\"0801198005264\",\"estado\":1,\"created_at\":\"2025-07-20T05:31:28.000000Z\",\"updated_at\":\"2025-07-20T05:32:42.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":25,\"nombres\":\"Hiuvert\",\"apellidos\":\"Maldonado\",\"usuario\":\"Hiuvert-M\",\"email\":\"hiavert.maldonado@unah.hn\",\"identidad\":\"0801198005264\",\"estado\":\"1\",\"created_at\":\"2025-07-20T05:31:28.000000Z\",\"updated_at\":\"2025-07-20T05:32:42.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-22 03:22:18', '2025-07-22 03:22:18'),
(88, 22, 'Hiavert Yohad Maldonado Ucles', 'crear', 'Usuario', 26, NULL, '{\"usuario\":\"Ramon-O\",\"nombres\":\"Ramon\",\"apellidos\":\"Osorio\",\"email\":\"ramon.a.osorio.r86@gmail.com\",\"identidad\":\"0801199910636\",\"estado\":\"1\",\"updated_at\":\"2025-07-22T04:40:44.000000Z\",\"created_at\":\"2025-07-22T04:40:44.000000Z\",\"id_usuario\":26}', '127.0.0.1', '2025-07-22 10:40:50', '2025-07-22 10:40:50'),
(89, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 1, '[{\"id_acceso\":104,\"fk_id_rol\":1,\"fk_id_objeto\":3,\"created_at\":\"2025-07-03T20:19:19.000000Z\",\"updated_at\":\"2025-07-03T20:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":105,\"fk_id_rol\":1,\"fk_id_objeto\":4,\"created_at\":\"2025-07-03T20:19:19.000000Z\",\"updated_at\":\"2025-07-03T20:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":106,\"fk_id_rol\":1,\"fk_id_objeto\":5,\"created_at\":\"2025-07-03T20:19:19.000000Z\",\"updated_at\":\"2025-07-03T20:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":5,\"nombre_objeto\":\"TareasDocumentales\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de tareas documentales\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":108,\"fk_id_rol\":1,\"fk_id_objeto\":7,\"created_at\":\"2025-07-03T20:19:19.000000Z\",\"updated_at\":\"2025-07-03T20:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":7,\"nombre_objeto\":\"Usuarios\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de usuarios\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":109,\"fk_id_rol\":1,\"fk_id_objeto\":8,\"created_at\":\"2025-07-03T20:19:19.000000Z\",\"updated_at\":\"2025-07-03T20:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":8,\"nombre_objeto\":\"Roles\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de roles y permisos\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":110,\"fk_id_rol\":1,\"fk_id_objeto\":9,\"created_at\":\"2025-07-03T20:19:19.000000Z\",\"updated_at\":\"2025-07-03T20:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":9,\"nombre_objeto\":\"Reportes\",\"tipo_objeto\":\"Reporte\",\"descripcion_objeto\":\"Generaci\\u00f3n de reportes\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":112,\"fk_id_rol\":1,\"fk_id_objeto\":11,\"created_at\":\"2025-07-03T20:19:19.000000Z\",\"updated_at\":\"2025-07-03T20:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":false,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":11,\"nombre_objeto\":\"Bitacora\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Vista general de todos los cambios que se realizan.\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T10:16:01.000000Z\",\"updated_at\":\"2025-07-01T21:15:49.000000Z\"}}]', '[{\"id_acceso\":185,\"fk_id_rol\":1,\"fk_id_objeto\":3,\"created_at\":\"2025-07-22T04:45:59.000000Z\",\"updated_at\":\"2025-07-22T04:45:59.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":186,\"fk_id_rol\":1,\"fk_id_objeto\":5,\"created_at\":\"2025-07-22T04:45:59.000000Z\",\"updated_at\":\"2025-07-22T04:45:59.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":5,\"nombre_objeto\":\"TareasDocumentales\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de tareas documentales\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":187,\"fk_id_rol\":1,\"fk_id_objeto\":13,\"created_at\":\"2025-07-22T04:45:59.000000Z\",\"updated_at\":\"2025-07-22T04:45:59.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":true,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":13,\"nombre_objeto\":\"GestionTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n Documental de Tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T01:59:18.000000Z\",\"updated_at\":\"2025-07-07T01:59:18.000000Z\"}}]', '127.0.0.1', '2025-07-22 10:45:59', '2025-07-22 10:45:59'),
(90, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 15, '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":1,\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":\"1\",\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-22 10:46:26', '2025-07-22 10:46:26'),
(91, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 1, '[{\"id_acceso\":185,\"fk_id_rol\":1,\"fk_id_objeto\":3,\"created_at\":\"2025-07-22T04:45:59.000000Z\",\"updated_at\":\"2025-07-22T04:45:59.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":186,\"fk_id_rol\":1,\"fk_id_objeto\":5,\"created_at\":\"2025-07-22T04:45:59.000000Z\",\"updated_at\":\"2025-07-22T04:45:59.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":5,\"nombre_objeto\":\"TareasDocumentales\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de tareas documentales\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":187,\"fk_id_rol\":1,\"fk_id_objeto\":13,\"created_at\":\"2025-07-22T04:45:59.000000Z\",\"updated_at\":\"2025-07-22T04:45:59.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":false,\"permiso_agregar\":true,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":13,\"nombre_objeto\":\"GestionTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n Documental de Tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T01:59:18.000000Z\",\"updated_at\":\"2025-07-07T01:59:18.000000Z\"}}]', '[{\"id_acceso\":188,\"fk_id_rol\":1,\"fk_id_objeto\":3,\"created_at\":\"2025-07-22T04:48:17.000000Z\",\"updated_at\":\"2025-07-22T04:48:17.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":189,\"fk_id_rol\":1,\"fk_id_objeto\":5,\"created_at\":\"2025-07-22T04:48:17.000000Z\",\"updated_at\":\"2025-07-22T04:48:17.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":5,\"nombre_objeto\":\"TareasDocumentales\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de tareas documentales\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":190,\"fk_id_rol\":1,\"fk_id_objeto\":13,\"created_at\":\"2025-07-22T04:48:17.000000Z\",\"updated_at\":\"2025-07-22T04:48:17.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":false,\"objeto\":{\"id_objeto\":13,\"nombre_objeto\":\"GestionTesis\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n Documental de Tesis\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-07T01:59:18.000000Z\",\"updated_at\":\"2025-07-07T01:59:18.000000Z\"}}]', '127.0.0.1', '2025-07-22 10:48:17', '2025-07-22 10:48:17'),
(92, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 25, '{\"id_usuario\":25,\"nombres\":\"Hiuvert\",\"apellidos\":\"Maldonado\",\"usuario\":\"Hiuvert-M\",\"email\":\"hiavert.maldonado@unah.hn\",\"identidad\":\"0801198005264\",\"estado\":1,\"created_at\":\"2025-07-20T05:31:28.000000Z\",\"updated_at\":\"2025-07-20T05:32:42.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":25,\"nombres\":\"Hiuvert\",\"apellidos\":\"Maldonado\",\"usuario\":\"Hiuvert-M\",\"email\":\"hiavert.maldonado@unah.hn\",\"identidad\":\"0801198005264\",\"estado\":\"1\",\"created_at\":\"2025-07-20T05:31:28.000000Z\",\"updated_at\":\"2025-07-20T05:32:42.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-22 11:06:06', '2025-07-22 11:06:06'),
(93, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 15, '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":1,\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":\"1\",\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-22 11:07:15', '2025-07-22 11:07:15'),
(94, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 15, '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":1,\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":\"1\",\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-22 11:07:29', '2025-07-22 11:07:29'),
(95, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 25, '{\"id_usuario\":25,\"nombres\":\"Hiuvert\",\"apellidos\":\"Maldonado\",\"usuario\":\"Hiuvert-M\",\"email\":\"hiavert.maldonado@unah.hn\",\"identidad\":\"0801198005264\",\"estado\":1,\"created_at\":\"2025-07-20T05:31:28.000000Z\",\"updated_at\":\"2025-07-20T05:32:42.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":25,\"nombres\":\"Hiuvert\",\"apellidos\":\"Maldonado\",\"usuario\":\"Hiuvert-M\",\"email\":\"hiavert.maldonado@unah.hn\",\"identidad\":\"0801198005264\",\"estado\":\"1\",\"created_at\":\"2025-07-20T05:31:28.000000Z\",\"updated_at\":\"2025-07-20T05:32:42.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-22 11:07:37', '2025-07-22 11:07:37'),
(96, 25, 'Hiuvert Maldonado', 'crear', 'Tarea', 22, NULL, '{\"nombre\":\"i0ojoinio\",\"descripcion\":\"ionionio\",\"fk_id_usuario_asignado\":\"26\",\"fk_id_usuario_creador\":\"25\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-22\",\"fecha_vencimiento\":\"2025-07-22\",\"updated_at\":\"2025-07-22T05:15:24.000000Z\",\"created_at\":\"2025-07-22T05:15:24.000000Z\",\"id_tarea\":22}', '127.0.0.1', '2025-07-22 11:15:24', '2025-07-22 11:15:24'),
(97, 25, 'Hiuvert Maldonado', 'editar', 'Tarea', 22, '{\"id_tarea\":22,\"fk_id_usuario_asignado\":26,\"fk_id_usuario_creador\":25,\"nombre\":\"i0ojoinio\",\"descripcion\":\"ionionio\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-22\",\"fecha_vencimiento\":\"2025-07-22\",\"created_at\":\"2025-07-22T05:15:24.000000Z\",\"updated_at\":\"2025-07-22T05:15:24.000000Z\",\"deleted_at\":null}', '{\"id_tarea\":22,\"fk_id_usuario_asignado\":\"26\",\"fk_id_usuario_creador\":\"25\",\"nombre\":\"i0ojoinio\",\"descripcion\":\"ionionio\",\"estado\":\"En Proceso\",\"fecha_creacion\":\"2025-07-22\",\"fecha_vencimiento\":null,\"created_at\":\"2025-07-22T05:15:24.000000Z\",\"updated_at\":\"2025-07-22T05:16:26.000000Z\",\"deleted_at\":null}', '127.0.0.1', '2025-07-22 11:16:26', '2025-07-22 11:16:26'),
(98, 25, 'Hiuvert Maldonado', 'cambiar_estado', 'Tarea', 22, '{\"estado\":\"Pendiente\"}', '{\"estado\":\"En Proceso\"}', '127.0.0.1', '2025-07-22 11:16:26', '2025-07-22 11:16:26'),
(99, 25, 'Hiuvert Maldonado', 'editar', 'Tarea', 21, '{\"id_tarea\":21,\"fk_id_usuario_asignado\":22,\"fk_id_usuario_creador\":22,\"nombre\":\"curriculum\",\"descripcion\":\"ioshgiogh\",\"estado\":\"Completada\",\"fecha_creacion\":\"2025-07-09\",\"fecha_vencimiento\":null,\"created_at\":\"2025-07-16T22:29:44.000000Z\",\"updated_at\":\"2025-07-21T04:51:29.000000Z\",\"deleted_at\":null}', '{\"id_tarea\":21,\"fk_id_usuario_asignado\":\"22\",\"fk_id_usuario_creador\":\"25\",\"nombre\":\"curriculum\",\"descripcion\":\"ioshgiogh\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-09\",\"fecha_vencimiento\":null,\"created_at\":\"2025-07-16T22:29:44.000000Z\",\"updated_at\":\"2025-07-22T05:16:51.000000Z\",\"deleted_at\":null}', '127.0.0.1', '2025-07-22 11:16:51', '2025-07-22 11:16:51'),
(100, 25, 'Hiuvert Maldonado', 'cambiar_estado', 'Tarea', 21, '{\"estado\":\"Completada\"}', '{\"estado\":\"Pendiente\"}', '127.0.0.1', '2025-07-22 11:16:51', '2025-07-22 11:16:51'),
(101, 25, 'Hiuvert Maldonado', 'editar', 'Tarea', 19, '{\"id_tarea\":19,\"fk_id_usuario_asignado\":20,\"fk_id_usuario_creador\":22,\"nombre\":\"curriculum\",\"descripcion\":\"ponete vivo a revisar\",\"estado\":\"Completada\",\"fecha_creacion\":\"2025-07-08\",\"fecha_vencimiento\":null,\"created_at\":\"2025-07-08T00:20:17.000000Z\",\"updated_at\":\"2025-07-21T04:51:06.000000Z\",\"deleted_at\":null}', '{\"id_tarea\":19,\"fk_id_usuario_asignado\":\"20\",\"fk_id_usuario_creador\":\"25\",\"nombre\":\"curriculum\",\"descripcion\":\"ponete vivo a revisar\",\"estado\":\"En Proceso\",\"fecha_creacion\":\"2025-07-08\",\"fecha_vencimiento\":null,\"created_at\":\"2025-07-08T00:20:17.000000Z\",\"updated_at\":\"2025-07-22T05:17:06.000000Z\",\"deleted_at\":null}', '127.0.0.1', '2025-07-22 11:17:06', '2025-07-22 11:17:06'),
(102, 25, 'Hiuvert Maldonado', 'cambiar_estado', 'Tarea', 19, '{\"estado\":\"Completada\"}', '{\"estado\":\"En Proceso\"}', '127.0.0.1', '2025-07-22 11:17:06', '2025-07-22 11:17:06'),
(103, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 15, '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":1,\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":15,\"nombres\":\"Usuario\",\"apellidos\":\"Admin\",\"usuario\":\"Usuario-Ejemplo\",\"email\":\"admin@unah.edu.hn\",\"identidad\":\"13224214\",\"estado\":\"1\",\"created_at\":\"2025-06-25T01:15:30.000000Z\",\"updated_at\":\"2025-07-03T13:43:07.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-22 14:32:49', '2025-07-22 14:32:49'),
(104, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 6, '[{\"id_acceso\":181,\"fk_id_rol\":6,\"fk_id_objeto\":3,\"created_at\":\"2025-07-21T21:19:19.000000Z\",\"updated_at\":\"2025-07-21T21:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":182,\"fk_id_rol\":6,\"fk_id_objeto\":4,\"created_at\":\"2025-07-21T21:19:19.000000Z\",\"updated_at\":\"2025-07-21T21:19:19.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '[{\"id_acceso\":191,\"fk_id_rol\":6,\"fk_id_objeto\":3,\"created_at\":\"2025-07-22T08:33:09.000000Z\",\"updated_at\":\"2025-07-22T08:33:09.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":192,\"fk_id_rol\":6,\"fk_id_objeto\":4,\"created_at\":\"2025-07-22T08:33:09.000000Z\",\"updated_at\":\"2025-07-22T08:33:09.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '127.0.0.1', '2025-07-22 14:33:09', '2025-07-22 14:33:09'),
(105, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Usuario', 25, '{\"id_usuario\":25,\"nombres\":\"Hiuvert\",\"apellidos\":\"Maldonado\",\"usuario\":\"Hiuvert-M\",\"email\":\"hiavert.maldonado@unah.hn\",\"identidad\":\"0801198005264\",\"estado\":1,\"created_at\":\"2025-07-20T05:31:28.000000Z\",\"updated_at\":\"2025-07-20T05:32:42.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '{\"id_usuario\":25,\"nombres\":\"Hiuvert\",\"apellidos\":\"Maldonado\",\"usuario\":\"Hiuvert-M\",\"email\":\"hiavert.maldonado@unah.hn\",\"identidad\":\"0801198005264\",\"estado\":\"1\",\"created_at\":\"2025-07-20T05:31:28.000000Z\",\"updated_at\":\"2025-07-20T05:32:42.000000Z\",\"deleted_at\":null,\"usr_add\":null}', '127.0.0.1', '2025-07-22 14:49:59', '2025-07-22 14:49:59'),
(106, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 6, '[{\"id_acceso\":191,\"fk_id_rol\":6,\"fk_id_objeto\":3,\"created_at\":\"2025-07-22T08:33:09.000000Z\",\"updated_at\":\"2025-07-22T08:33:09.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":192,\"fk_id_rol\":6,\"fk_id_objeto\":4,\"created_at\":\"2025-07-22T08:33:09.000000Z\",\"updated_at\":\"2025-07-22T08:33:09.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":4,\"nombre_objeto\":\"Terna\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Gesti\\u00f3n de pagos de terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}}]', '[{\"id_acceso\":193,\"fk_id_rol\":6,\"fk_id_objeto\":3,\"created_at\":\"2025-07-24T07:53:32.000000Z\",\"updated_at\":\"2025-07-24T07:53:32.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":194,\"fk_id_rol\":6,\"fk_id_objeto\":17,\"created_at\":\"2025-07-24T07:53:32.000000Z\",\"updated_at\":\"2025-07-24T07:53:32.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":17,\"nombre_objeto\":\"TernaAux\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Modulo de Asistente de Terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-24T01:53:11.000000Z\",\"updated_at\":\"2025-07-24T01:53:11.000000Z\"}}]', '127.0.0.1', '2025-07-24 13:53:32', '2025-07-24 13:53:32'),
(107, 22, 'Hiavert Yohad Maldonado Ucles', 'actualizar_permisos', 'Rol', 6, '[{\"id_acceso\":193,\"fk_id_rol\":6,\"fk_id_objeto\":3,\"created_at\":\"2025-07-24T07:53:32.000000Z\",\"updated_at\":\"2025-07-24T07:53:32.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":194,\"fk_id_rol\":6,\"fk_id_objeto\":17,\"created_at\":\"2025-07-24T07:53:32.000000Z\",\"updated_at\":\"2025-07-24T07:53:32.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":17,\"nombre_objeto\":\"TernaAux\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Modulo de Asistente de Terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-24T01:53:11.000000Z\",\"updated_at\":\"2025-07-24T01:53:11.000000Z\"}}]', '[{\"id_acceso\":195,\"fk_id_rol\":6,\"fk_id_objeto\":3,\"created_at\":\"2025-07-28T23:04:29.000000Z\",\"updated_at\":\"2025-07-28T23:04:29.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":3,\"nombre_objeto\":\"dashboard\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Panel principal\",\"estado_objeto\":\"1\",\"created_at\":\"2025-06-25T08:30:56.000000Z\",\"updated_at\":\"2025-06-25T08:30:56.000000Z\"}},{\"id_acceso\":196,\"fk_id_rol\":6,\"fk_id_objeto\":17,\"created_at\":\"2025-07-28T23:04:29.000000Z\",\"updated_at\":\"2025-07-28T23:04:29.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":17,\"nombre_objeto\":\"TernaAux\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Modulo de Asistente de Terna\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-24T01:53:11.000000Z\",\"updated_at\":\"2025-07-24T01:53:11.000000Z\"}},{\"id_acceso\":197,\"fk_id_rol\":6,\"fk_id_objeto\":19,\"created_at\":\"2025-07-28T23:04:29.000000Z\",\"updated_at\":\"2025-07-28T23:04:29.000000Z\",\"permiso\":true,\"permiso_ver\":true,\"permiso_editar\":true,\"permiso_agregar\":true,\"permiso_eliminar\":true,\"objeto\":{\"id_objeto\":19,\"nombre_objeto\":\"Recepcion\",\"tipo_objeto\":\"M\\u00f3dulo\",\"descripcion_objeto\":\"Modulo de recepcion de archivos para usuarios\",\"estado_objeto\":\"1\",\"created_at\":\"2025-07-28T15:28:06.000000Z\",\"updated_at\":\"2025-07-28T15:28:06.000000Z\"}}]', '127.0.0.1', '2025-07-29 05:04:29', '2025-07-29 05:04:29'),
(108, 22, 'Hiavert Yohad Maldonado Ucles', 'crear', 'Tarea', 23, NULL, '{\"nombre\":\"Expediente de ingreso\",\"descripcion\":\"Urgente\",\"fk_id_usuario_asignado\":\"25\",\"fk_id_usuario_creador\":\"22\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-29\",\"fecha_vencimiento\":\"2025-08-07\",\"updated_at\":\"2025-07-30T00:57:03.000000Z\",\"created_at\":\"2025-07-30T00:57:03.000000Z\",\"id_tarea\":23}', '127.0.0.1', '2025-07-30 06:57:03', '2025-07-30 06:57:03'),
(109, 22, 'Hiavert Yohad Maldonado Ucles', 'cargar_documento', 'Documento', 8, NULL, '{\"nombre_documento\":\"Formatos Ceramica.pdf\",\"descripcion\":null,\"ruta_archivo\":\"tareas_documentos\\/CfhNMfO5C1nKGUvIK6rijlasnxovSMPThhAl0Fcd.pdf\",\"fecha_subida\":\"2025-07-30T00:59:08.020498Z\",\"fk_id_usuario\":22,\"fk_id_tipo\":\"1\",\"updated_at\":\"2025-07-30T00:59:08.000000Z\",\"created_at\":\"2025-07-30T00:59:08.000000Z\",\"id_documento\":8}', '127.0.0.1', '2025-07-30 06:59:08', '2025-07-30 06:59:08'),
(110, 22, 'Hiavert Yohad Maldonado Ucles', 'asociar_documento', 'Tarea', 23, NULL, '{\"id_documento\":8}', '127.0.0.1', '2025-07-30 06:59:08', '2025-07-30 06:59:08'),
(111, 22, 'Hiavert Yohad Maldonado Ucles', 'eliminar', 'Tarea', 17, '{\"id_tarea\":17,\"fk_id_usuario_asignado\":15,\"fk_id_usuario_creador\":22,\"nombre\":\"imformme\",\"descripcion\":\"realizar informe\",\"estado\":\"Completada\",\"fecha_creacion\":\"2025-07-07\",\"fecha_vencimiento\":null,\"created_at\":\"2025-07-07T20:22:08.000000Z\",\"updated_at\":\"2025-07-16T22:10:49.000000Z\",\"deleted_at\":null}', NULL, '127.0.0.1', '2025-07-30 07:02:12', '2025-07-30 07:02:12'),
(112, 22, 'Hiavert Yohad Maldonado Ucles', 'editar', 'Tarea', 23, '{\"id_tarea\":23,\"fk_id_usuario_asignado\":25,\"fk_id_usuario_creador\":22,\"nombre\":\"Expediente de ingreso\",\"descripcion\":\"Urgente\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-29\",\"fecha_vencimiento\":\"2025-08-07\",\"created_at\":\"2025-07-30T00:57:03.000000Z\",\"updated_at\":\"2025-07-30T00:57:03.000000Z\",\"deleted_at\":null}', '{\"id_tarea\":23,\"fk_id_usuario_asignado\":\"26\",\"fk_id_usuario_creador\":\"22\",\"nombre\":\"Expediente de ingreso\",\"descripcion\":\"Urgente\",\"estado\":\"Pendiente\",\"fecha_creacion\":\"2025-07-29\",\"fecha_vencimiento\":null,\"created_at\":\"2025-07-30T00:57:03.000000Z\",\"updated_at\":\"2025-07-30T01:05:12.000000Z\",\"deleted_at\":null}', '127.0.0.1', '2025-07-30 07:05:12', '2025-07-30 07:05:12');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `documentos`
--

CREATE TABLE `documentos` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tipo` varchar(255) NOT NULL,
  `numero` varchar(255) DEFAULT NULL,
  `remitente` varchar(255) NOT NULL,
  `destinatario` varchar(255) NOT NULL,
  `asunto` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `archivo_path` varchar(255) NOT NULL,
  `fecha_documento` date NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `documentos`
--

INSERT INTO `documentos` (`id`, `tipo`, `numero`, `remitente`, `destinatario`, `asunto`, `descripcion`, `archivo_path`, `fecha_documento`, `user_id`, `created_at`, `updated_at`) VALUES
(1, 'oficio', 'OF-2025-001', 'DIPP', 'Lic Carlos guzman', 'Aplicacion de memorandum', 'se describe la situacion actual con los horarios incumplidos', 'documentos/bQCTvQ5z22AHXjymhdnVsYu8vTXWHDAXNRMZ0w7n.pdf', '2025-07-28', 22, '2025-07-29 04:24:21', '2025-07-29 04:24:21');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `documentos_terna`
--

CREATE TABLE `documentos_terna` (
  `id` bigint(20) NOT NULL,
  `pago_terna_id` bigint(20) DEFAULT NULL,
  `tipo` enum('documento_fisico','solvencia_cobranza','acta_graduacion','constancia_participacion','orden_pago','propuesta_maestria') DEFAULT NULL,
  `ruta_archivo` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `documentos_terna`
--

INSERT INTO `documentos_terna` (`id`, `pago_terna_id`, `tipo`, `ruta_archivo`, `created_at`, `updated_at`) VALUES
(1, 1, 'documento_fisico', 'public/documentos_terna/73mE1XSRv5AM2OEuLrbKCqyUgnwP6tJYVjBfuQz0.pdf', '2025-07-24 13:47:32', '2025-07-24 13:47:32'),
(2, 1, 'solvencia_cobranza', 'public/documentos_terna/VuxFA0CKFj1a5tpx8dnkBbOcj6oI0FK07ekZFI3j.pdf', '2025-07-24 13:47:32', '2025-07-24 13:47:32'),
(3, 1, 'acta_graduacion', 'public/documentos_terna/CiD3QtGyHKHDCEH73EvixrU7LnRCvhb4ND3VIvuI.pdf', '2025-07-24 13:47:32', '2025-07-24 13:47:32'),
(4, 1, 'constancia_participacion', 'public/documentos_terna/5UnjZp5Z8nJLHm8oDATLOdwRrXTsfdMmo9Z6Jhid.pdf', '2025-07-24 13:54:23', '2025-07-24 13:54:23'),
(5, 1, 'orden_pago', 'public/documentos_terna/uNHlAVgw9g2K0mISkepfL11i1kbIDhPy8SUcepEL.pdf', '2025-07-24 13:54:23', '2025-07-24 13:54:23'),
(6, 1, 'propuesta_maestria', 'public/documentos_terna/NAIPl4WxshnIVizoBRXUoFmIe9te2hrsWVhxTpGa.pdf', '2025-07-24 13:54:23', '2025-07-24 13:54:23'),
(7, 2, 'documento_fisico', 'public/documentos_terna/lic-hiavert_1753345693_Formatos Ceramica.pdf', '2025-07-24 14:28:13', '2025-07-24 14:28:13'),
(8, 2, 'solvencia_cobranza', 'public/documentos_terna/lic-hiavert_1753345693_Formatos Ceramica.pdf', '2025-07-24 14:28:13', '2025-07-24 14:28:13'),
(9, 2, 'acta_graduacion', 'public/documentos_terna/lic-hiavert_1753345693_Formatos Ceramica.pdf', '2025-07-24 14:28:13', '2025-07-24 14:28:13'),
(10, 2, 'constancia_participacion', 'public/documentos_terna/lic-hiavert_1753346216_Formatos Ceramica.pdf', '2025-07-24 14:36:56', '2025-07-24 14:36:56'),
(11, 2, 'orden_pago', 'public/documentos_terna/lic-hiavert_1753346216_Formatos Ceramica.pdf', '2025-07-24 14:36:56', '2025-07-24 14:36:56'),
(12, 2, 'propuesta_maestria', 'public/documentos_terna/lic-hiavert_1753346216_Formatos Ceramica.pdf', '2025-07-24 14:36:56', '2025-07-24 14:36:56'),
(13, 3, 'documento_fisico', 'lic-carverucles_1753349890_Formatos Ceramica.pdf', '2025-07-24 15:38:10', '2025-07-24 15:38:10'),
(14, 3, 'solvencia_cobranza', 'lic-carverucles_1753349890_Formatos Ceramica.pdf', '2025-07-24 15:38:10', '2025-07-24 15:38:10'),
(15, 3, 'acta_graduacion', 'lic-carverucles_1753349890_Formatos Ceramica.pdf', '2025-07-24 15:38:10', '2025-07-24 15:38:10'),
(16, 4, 'documento_fisico', 'yagermaister_1753350926_Formatos Ceramica.pdf', '2025-07-24 15:55:26', '2025-07-24 15:55:26'),
(17, 4, 'solvencia_cobranza', 'yagermaister_1753350926_Formatos Ceramica.pdf', '2025-07-24 15:55:26', '2025-07-24 15:55:26'),
(18, 4, 'acta_graduacion', 'yagermaister_1753350926_Formatos Ceramica.pdf', '2025-07-24 15:55:26', '2025-07-24 15:55:26'),
(19, 5, 'documento_fisico', 'lic-yarber_1753387474_Formatos Ceramica.pdf', '2025-07-25 02:04:34', '2025-07-25 02:04:34'),
(20, 5, 'solvencia_cobranza', 'lic-yarber_1753387474_Formatos Ceramica.pdf', '2025-07-25 02:04:34', '2025-07-25 02:04:34'),
(21, 5, 'acta_graduacion', 'lic-yarber_1753387474_Formatos Ceramica.pdf', '2025-07-25 02:04:34', '2025-07-25 02:04:34'),
(22, 6, 'documento_fisico', 'formatos-ceramica.pdf', '2025-07-25 02:41:08', '2025-07-25 02:41:08'),
(23, 6, 'solvencia_cobranza', 'formatos-ceramica.pdf', '2025-07-25 02:41:08', '2025-07-25 02:41:08'),
(24, 6, 'acta_graduacion', 'formatos-ceramica.pdf', '2025-07-25 02:41:08', '2025-07-25 02:41:08'),
(25, 6, 'constancia_participacion', 'identidad.pdf', '2025-07-25 02:47:12', '2025-07-25 02:47:12'),
(26, 6, 'orden_pago', 'hiavert-yohad-maldonado-ucles.pdf', '2025-07-25 02:47:12', '2025-07-25 02:47:12'),
(27, 6, 'propuesta_maestria', 'cv-hiavertmaldonado.pdf', '2025-07-25 02:47:12', '2025-07-25 02:47:12'),
(28, 7, 'documento_fisico', 'bqctvq5z22ahxjymhdnvsyu8vtxwhdaxnrmz0w7n.pdf', '2025-07-30 00:47:37', '2025-07-30 00:47:37'),
(29, 7, 'solvencia_cobranza', 'bqctvq5z22ahxjymhdnvsyu8vtxwhdaxnrmz0w7n.pdf', '2025-07-30 00:47:37', '2025-07-30 00:47:37'),
(30, 7, 'acta_graduacion', 'bqctvq5z22ahxjymhdnvsyu8vtxwhdaxnrmz0w7n.pdf', '2025-07-30 00:47:37', '2025-07-30 00:47:37'),
(31, 8, 'documento_fisico', 'formatos-ceramica.pdf', '2025-07-30 06:22:40', '2025-07-30 06:22:40'),
(32, 8, 'solvencia_cobranza', 'formatos-ceramica.pdf', '2025-07-30 06:22:40', '2025-07-30 06:22:40'),
(33, 8, 'acta_graduacion', 'formatos-ceramica.pdf', '2025-07-30 06:22:40', '2025-07-30 06:22:40'),
(34, 8, 'constancia_participacion', 'formatos-ceramica.pdf', '2025-07-30 06:45:35', '2025-07-30 06:45:35'),
(35, 8, 'orden_pago', 'formatos-ceramica.pdf', '2025-07-30 06:45:35', '2025-07-30 06:45:35'),
(36, 8, 'propuesta_maestria', 'formatos-ceramica.pdf', '2025-07-30 06:45:35', '2025-07-30 06:45:35');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `documento_administrativo`
--

CREATE TABLE `documento_administrativo` (
  `id_documento` int(11) NOT NULL,
  `fk_id_usuario` int(11) NOT NULL,
  `fk_id_tipo` int(10) UNSIGNED DEFAULT NULL,
  `nombre_documento` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `ruta_archivo` varchar(255) NOT NULL,
  `fecha_subida` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `documento_administrativo`
--

INSERT INTO `documento_administrativo` (`id_documento`, `fk_id_usuario`, `fk_id_tipo`, `nombre_documento`, `descripcion`, `ruta_archivo`, `fecha_subida`, `created_at`, `updated_at`, `deleted_at`) VALUES
(6, 22, 1, 'Captura de pantalla 2024-11-25 222410.png', NULL, 'tareas_documentos/fBK6as1Jzd2zqNPImMhF1qFjK0KXiITb4t6gTUBa.png', '2025-07-08', '2025-07-08 06:20:48', '2025-07-08 06:20:48', NULL),
(7, 22, 1, 'Captura de pantalla 2024-12-04 213434.png', NULL, 'tareas_documentos/vDY35MX7T5sosZzoe0XyabctYZ0ji1g4YOxbNd4W.png', '2025-07-08', '2025-07-08 06:21:10', '2025-07-08 06:21:10', NULL),
(8, 22, 1, 'Formatos Ceramica.pdf', NULL, 'tareas_documentos/CfhNMfO5C1nKGUvIK6rijlasnxovSMPThhAl0Fcd.pdf', '2025-07-30', '2025-07-30 06:59:08', '2025-07-30 06:59:08', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `documento_envios`
--

CREATE TABLE `documento_envios` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `documento_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` int(11) NOT NULL,
  `mensaje` text DEFAULT NULL,
  `leido` tinyint(1) NOT NULL DEFAULT 0,
  `fecha_leido` timestamp NULL DEFAULT NULL,
  `enviado_por` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `documento_envios`
--

INSERT INTO `documento_envios` (`id`, `documento_id`, `user_id`, `mensaje`, `leido`, `fecha_leido`, `enviado_por`, `created_at`, `updated_at`) VALUES
(1, 1, 15, 'aqui tienes este oficio para ti', 1, '2025-07-30 02:22:02', 22, '2025-07-29 05:01:58', '2025-07-30 02:22:02'),
(4, 1, 15, NULL, 0, NULL, 22, '2025-07-30 02:21:07', '2025-07-30 02:21:07'),
(5, 1, 25, NULL, 0, NULL, 22, '2025-07-30 02:21:07', '2025-07-30 02:21:07');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `elementos`
--

CREATE TABLE `elementos` (
  `id_elemento` int(11) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `cantidad` int(11) DEFAULT 1,
  `fk_id_tipo` int(11) NOT NULL,
  `fk_id_acuse` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `elementos`
--

INSERT INTO `elementos` (`id_elemento`, `nombre`, `descripcion`, `cantidad`, `fk_id_tipo`, `fk_id_acuse`, `created_at`, `updated_at`) VALUES
(9, 'xd', 'xd', 1, 1, 9, '2025-07-07 15:39:13', '2025-07-07 15:39:13'),
(10, 'documento tesis', 'docunentos', 1, 1, 10, '2025-07-17 07:02:49', '2025-07-17 07:02:49'),
(11, 'fichero pixa', 'no estaba en el dos mil y pico na', 2, 2, 11, '2025-07-21 09:36:10', '2025-07-21 09:36:10'),
(12, 'Expediente Sara', 'en este expediente se guaada el registro de la susodicha', 1, 4, 12, '2025-07-21 11:24:04', '2025-07-21 11:24:04'),
(13, 'fichero pixa', '51515', 1, 3, 13, '2025-07-21 12:16:06', '2025-07-21 12:16:06'),
(14, 'dgsgsg', 'sgdsdg', 1, 3, 14, '2025-07-21 12:26:04', '2025-07-21 12:26:04'),
(15, 'asfafs', 'fasfaf', 1, 2, 15, '2025-07-21 12:29:02', '2025-07-21 12:29:02'),
(18, 'asfafs', NULL, 1, 3, 18, '2025-07-21 12:50:58', '2025-07-21 12:50:58'),
(19, 'perro', 'perroloco', 1, 1, 19, '2025-07-22 11:01:31', '2025-07-22 11:01:31');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado_documento`
--

CREATE TABLE `estado_documento` (
  `id_estado` int(11) NOT NULL,
  `descripcion` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `estado_documento`
--

INSERT INTO `estado_documento` (`id_estado`, `descripcion`, `created_at`, `updated_at`) VALUES
(1, 'Pendiente', '2025-07-04 22:29:48', '2025-07-04 22:29:48'),
(2, 'En Revisión', '2025-07-04 22:29:48', '2025-07-04 22:29:48'),
(3, 'Validada', '2025-07-04 22:29:48', '2025-07-04 22:29:48'),
(4, 'Rechazada', '2025-07-04 22:29:48', '2025-07-04 22:29:48');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado_pago`
--

CREATE TABLE `estado_pago` (
  `id_estado_pago` int(11) NOT NULL,
  `descripcion` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `expediente_docente`
--

CREATE TABLE `expediente_docente` (
  `id_expediente_docente` int(11) NOT NULL,
  `fk_id_persona` int(11) NOT NULL,
  `facultad` varchar(100) NOT NULL,
  `cargo` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `expediente_estudiantil`
--

CREATE TABLE `expediente_estudiantil` (
  `id_expediente_estudiantil` int(11) NOT NULL,
  `fk_id_persona` int(11) NOT NULL,
  `facultad` varchar(100) NOT NULL,
  `carrera` varchar(100) NOT NULL,
  `fecha_ingreso` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `jobs`
--

INSERT INTO `jobs` (`id`, `queue`, `payload`, `attempts`, `reserved_at`, `available_at`, `created_at`) VALUES
(1, 'default', '{\"uuid\":\"7e44f7af-d5f4-4e84-bd25-4e1706ec41b7\",\"displayName\":\"App\\\\Notifications\\\\TareaAsignadaNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\",\"command\":\"O:48:\\\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\\\":3:{s:11:\\\"notifiables\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";a:1:{i:0;i:20;}s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:12:\\\"notification\\\";O:43:\\\"App\\\\Notifications\\\\TareaAsignadaNotification\\\":2:{s:5:\\\"tarea\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:16:\\\"App\\\\Models\\\\Tarea\\\";s:2:\\\"id\\\";i:4;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:2:\\\"id\\\";s:36:\\\"f84fc58b-8f28-4e45-a590-c907e0340da2\\\";}s:8:\\\"channels\\\";a:1:{i:0;s:4:\\\"mail\\\";}}\"},\"createdAt\":1751512813,\"delay\":null}', 0, NULL, 1751512813, 1751512813),
(2, 'default', '{\"uuid\":\"6582edbd-14df-442b-8d11-bd400bb2a4ad\",\"displayName\":\"App\\\\Notifications\\\\TareaAsignadaNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\",\"command\":\"O:48:\\\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\\\":3:{s:11:\\\"notifiables\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";a:1:{i:0;i:20;}s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:12:\\\"notification\\\";O:43:\\\"App\\\\Notifications\\\\TareaAsignadaNotification\\\":2:{s:5:\\\"tarea\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:16:\\\"App\\\\Models\\\\Tarea\\\";s:2:\\\"id\\\";i:4;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:2:\\\"id\\\";s:36:\\\"f84fc58b-8f28-4e45-a590-c907e0340da2\\\";}s:8:\\\"channels\\\";a:1:{i:0;s:8:\\\"database\\\";}}\"},\"createdAt\":1751512813,\"delay\":null}', 0, NULL, 1751512813, 1751512813),
(3, 'default', '{\"uuid\":\"774de636-49e5-48eb-be3c-9bad1f701a78\",\"displayName\":\"App\\\\Notifications\\\\TareaAsignadaNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\",\"command\":\"O:48:\\\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\\\":3:{s:11:\\\"notifiables\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";a:1:{i:0;i:20;}s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:12:\\\"notification\\\";O:43:\\\"App\\\\Notifications\\\\TareaAsignadaNotification\\\":2:{s:5:\\\"tarea\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:16:\\\"App\\\\Models\\\\Tarea\\\";s:2:\\\"id\\\";i:5;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:2:\\\"id\\\";s:36:\\\"9ed50009-9139-4c9a-8da2-d23eb6e6688b\\\";}s:8:\\\"channels\\\";a:1:{i:0;s:4:\\\"mail\\\";}}\"},\"createdAt\":1751513314,\"delay\":null}', 0, NULL, 1751513314, 1751513314),
(4, 'default', '{\"uuid\":\"16075e1b-407c-4062-9fb4-20960160b14f\",\"displayName\":\"App\\\\Notifications\\\\TareaAsignadaNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\",\"command\":\"O:48:\\\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\\\":3:{s:11:\\\"notifiables\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";a:1:{i:0;i:20;}s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:12:\\\"notification\\\";O:43:\\\"App\\\\Notifications\\\\TareaAsignadaNotification\\\":2:{s:5:\\\"tarea\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:16:\\\"App\\\\Models\\\\Tarea\\\";s:2:\\\"id\\\";i:5;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:2:\\\"id\\\";s:36:\\\"9ed50009-9139-4c9a-8da2-d23eb6e6688b\\\";}s:8:\\\"channels\\\";a:1:{i:0;s:8:\\\"database\\\";}}\"},\"createdAt\":1751513314,\"delay\":null}', 0, NULL, 1751513314, 1751513314),
(5, 'default', '{\"uuid\":\"41c253dc-6e46-4d8e-afb1-9a4692f22866\",\"displayName\":\"App\\\\Notifications\\\\TareaAsignadaNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\",\"command\":\"O:48:\\\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\\\":3:{s:11:\\\"notifiables\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";a:1:{i:0;i:20;}s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:12:\\\"notification\\\";O:43:\\\"App\\\\Notifications\\\\TareaAsignadaNotification\\\":2:{s:5:\\\"tarea\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:16:\\\"App\\\\Models\\\\Tarea\\\";s:2:\\\"id\\\";i:6;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:2:\\\"id\\\";s:36:\\\"60aa8ad0-dc82-4965-b5d6-8a4ebfbe784a\\\";}s:8:\\\"channels\\\";a:1:{i:0;s:4:\\\"mail\\\";}}\"},\"createdAt\":1751514564,\"delay\":null}', 0, NULL, 1751514564, 1751514564),
(6, 'default', '{\"uuid\":\"9051a56a-7f03-41bb-a381-86c2fca7a8bf\",\"displayName\":\"App\\\\Notifications\\\\TareaAsignadaNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\",\"command\":\"O:48:\\\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\\\":3:{s:11:\\\"notifiables\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";a:1:{i:0;i:20;}s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:12:\\\"notification\\\";O:43:\\\"App\\\\Notifications\\\\TareaAsignadaNotification\\\":2:{s:5:\\\"tarea\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:16:\\\"App\\\\Models\\\\Tarea\\\";s:2:\\\"id\\\";i:6;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:2:\\\"id\\\";s:36:\\\"60aa8ad0-dc82-4965-b5d6-8a4ebfbe784a\\\";}s:8:\\\"channels\\\";a:1:{i:0;s:8:\\\"database\\\";}}\"},\"createdAt\":1751514564,\"delay\":null}', 0, NULL, 1751514564, 1751514564),
(7, 'default', '{\"uuid\":\"e8753fd6-f7dc-4916-bd53-223357986276\",\"displayName\":\"App\\\\Notifications\\\\TareaAsignadaNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\",\"command\":\"O:48:\\\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\\\":3:{s:11:\\\"notifiables\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";a:1:{i:0;i:20;}s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:12:\\\"notification\\\";O:43:\\\"App\\\\Notifications\\\\TareaAsignadaNotification\\\":2:{s:5:\\\"tarea\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:16:\\\"App\\\\Models\\\\Tarea\\\";s:2:\\\"id\\\";i:7;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:2:\\\"id\\\";s:36:\\\"253aa974-9998-47b3-9b7e-ea1b7c25e7b4\\\";}s:8:\\\"channels\\\";a:1:{i:0;s:4:\\\"mail\\\";}}\"},\"createdAt\":1751566405,\"delay\":null}', 0, NULL, 1751566406, 1751566406),
(8, 'default', '{\"uuid\":\"6dbf6776-6c66-415e-9e92-775e6b9740b8\",\"displayName\":\"App\\\\Notifications\\\\TareaAsignadaNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\",\"command\":\"O:48:\\\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\\\":3:{s:11:\\\"notifiables\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";a:1:{i:0;i:20;}s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:12:\\\"notification\\\";O:43:\\\"App\\\\Notifications\\\\TareaAsignadaNotification\\\":2:{s:5:\\\"tarea\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:16:\\\"App\\\\Models\\\\Tarea\\\";s:2:\\\"id\\\";i:7;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:2:\\\"id\\\";s:36:\\\"253aa974-9998-47b3-9b7e-ea1b7c25e7b4\\\";}s:8:\\\"channels\\\";a:1:{i:0;s:8:\\\"database\\\";}}\"},\"createdAt\":1751566406,\"delay\":null}', 0, NULL, 1751566406, 1751566406),
(9, 'default', '{\"uuid\":\"adc47f13-217e-4d7c-ae95-0bdc82789a90\",\"displayName\":\"App\\\\Notifications\\\\DocumentoRecibidoNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\",\"command\":\"O:48:\\\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\\\":3:{s:11:\\\"notifiables\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";a:1:{i:0;i:15;}s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:12:\\\"notification\\\";O:47:\\\"App\\\\Notifications\\\\DocumentoRecibidoNotification\\\":3:{s:9:\\\"documento\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:20:\\\"App\\\\Models\\\\Documento\\\";s:2:\\\"id\\\";i:1;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"enviadoPor\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";i:22;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:2:\\\"id\\\";s:36:\\\"d03c27d4-3fe1-472d-ab23-cc9e571d8ab0\\\";}s:8:\\\"channels\\\";a:1:{i:0;s:8:\\\"database\\\";}}\"},\"createdAt\":1753743722,\"delay\":null}', 0, NULL, 1753743722, 1753743722),
(10, 'default', '{\"uuid\":\"0ef6d47a-2812-4f23-8db2-7d61ea0dd6e3\",\"displayName\":\"App\\\\Notifications\\\\DocumentoRecibidoNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\",\"command\":\"O:48:\\\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\\\":3:{s:11:\\\"notifiables\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";a:1:{i:0;i:15;}s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:12:\\\"notification\\\";O:47:\\\"App\\\\Notifications\\\\DocumentoRecibidoNotification\\\":3:{s:9:\\\"documento\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:20:\\\"App\\\\Models\\\\Documento\\\";s:2:\\\"id\\\";i:2;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"enviadoPor\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";i:22;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:2:\\\"id\\\";s:36:\\\"76e35ce0-fcfe-4135-8bde-9b70eff397ea\\\";}s:8:\\\"channels\\\";a:1:{i:0;s:8:\\\"database\\\";}}\"},\"createdAt\":1753815954,\"delay\":null}', 0, NULL, 1753815954, 1753815954),
(11, 'default', '{\"uuid\":\"db63063e-b4c4-48c1-9f38-cf177415a2dc\",\"displayName\":\"App\\\\Notifications\\\\DocumentoRecibidoNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\",\"command\":\"O:48:\\\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\\\":3:{s:11:\\\"notifiables\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";a:1:{i:0;i:25;}s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:12:\\\"notification\\\";O:47:\\\"App\\\\Notifications\\\\DocumentoRecibidoNotification\\\":3:{s:9:\\\"documento\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:20:\\\"App\\\\Models\\\\Documento\\\";s:2:\\\"id\\\";i:2;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"enviadoPor\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";i:22;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:2:\\\"id\\\";s:36:\\\"11239b14-6dd4-49ec-bee3-e93c5f8f08ea\\\";}s:8:\\\"channels\\\";a:1:{i:0;s:8:\\\"database\\\";}}\"},\"createdAt\":1753815954,\"delay\":null}', 0, NULL, 1753815954, 1753815954),
(12, 'default', '{\"uuid\":\"3fad88e4-d771-431c-a18b-1c13201679d1\",\"displayName\":\"App\\\\Notifications\\\\DocumentoRecibidoNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\",\"command\":\"O:48:\\\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\\\":3:{s:11:\\\"notifiables\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";a:1:{i:0;i:15;}s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:12:\\\"notification\\\";O:47:\\\"App\\\\Notifications\\\\DocumentoRecibidoNotification\\\":3:{s:9:\\\"documento\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:20:\\\"App\\\\Models\\\\Documento\\\";s:2:\\\"id\\\";i:1;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"enviadoPor\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";i:22;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:2:\\\"id\\\";s:36:\\\"d1d3a7c4-b98d-4bb0-a46d-48b50550c62e\\\";}s:8:\\\"channels\\\";a:1:{i:0;s:8:\\\"database\\\";}}\"},\"createdAt\":1753820467,\"delay\":null}', 0, NULL, 1753820467, 1753820467),
(13, 'default', '{\"uuid\":\"5eb921fb-1da6-4f00-a880-449a83f9f79a\",\"displayName\":\"App\\\\Notifications\\\\DocumentoRecibidoNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\",\"command\":\"O:48:\\\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\\\":3:{s:11:\\\"notifiables\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";a:1:{i:0;i:25;}s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:12:\\\"notification\\\";O:47:\\\"App\\\\Notifications\\\\DocumentoRecibidoNotification\\\":3:{s:9:\\\"documento\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:20:\\\"App\\\\Models\\\\Documento\\\";s:2:\\\"id\\\";i:1;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"enviadoPor\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";i:22;s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:2:\\\"id\\\";s:36:\\\"4e4d4530-5f39-41f6-a08b-905ad31eb071\\\";}s:8:\\\"channels\\\";a:1:{i:0;s:8:\\\"database\\\";}}\"},\"createdAt\":1753820467,\"delay\":null}', 0, NULL, 1753820467, 1753820467);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log_login`
--

CREATE TABLE `log_login` (
  `id_log` int(11) NOT NULL,
  `fk_id_usuario` int(11) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  `estado_login` enum('Éxito','Fallo') NOT NULL,
  `ip` varchar(50) DEFAULT NULL,
  `dispositivo` varchar(255) DEFAULT NULL,
  `descripcion` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notificaciones`
--

CREATE TABLE `notificaciones` (
  `id_notificacion` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `mensaje` text DEFAULT NULL,
  `fk_id_usuario_destinatario` int(11) NOT NULL,
  `fk_id_acuse` int(11) NOT NULL,
  `estado` enum('leida','no_leida') DEFAULT 'no_leida',
  `fecha` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `notificaciones`
--

INSERT INTO `notificaciones` (`id_notificacion`, `titulo`, `mensaje`, `fk_id_usuario_destinatario`, `fk_id_acuse`, `estado`, `fecha`, `created_at`, `updated_at`) VALUES
(11, 'Nuevo acuse de recibo', 'Tienes un nuevo acuse de recibo de Hiavert Yohad', 15, 9, 'leida', '2025-07-07 09:39:13', '2025-07-07 15:39:13', '2025-07-07 15:41:20'),
(12, 'Nuevo acuse de recibo', 'Tienes un nuevo acuse de recibo de Hiavert Yohad', 15, 10, 'leida', '2025-07-17 01:02:49', '2025-07-17 07:02:49', '2025-07-21 09:13:36'),
(13, 'Nuevo acuse de recibo', 'Tienes un nuevo acuse de recibo de Usuario', 22, 11, 'leida', '2025-07-21 03:36:10', '2025-07-21 09:36:10', '2025-07-21 09:41:02'),
(14, 'Acuse reenviado', 'Se te ha reenviado un acuse de Usuario', 25, 10, 'leida', '2025-07-21 05:11:26', '2025-07-21 11:11:26', '2025-07-21 11:13:01'),
(15, 'Acuse reenviado', 'Se te ha reenviado un acuse de Hiuvert', 22, 10, 'leida', '2025-07-21 05:12:55', '2025-07-21 11:12:55', '2025-07-21 11:13:35'),
(16, 'Nuevo acuse de recibo', 'Tienes un nuevo acuse de recibo de Hiavert Yohad', 25, 12, 'leida', '2025-07-21 05:24:04', '2025-07-21 11:24:04', '2025-07-21 11:25:57'),
(17, 'Nuevo acuse de recibo', 'Tienes un nuevo acuse de recibo de Hiavert Yohad', 25, 13, 'leida', '2025-07-21 06:16:06', '2025-07-21 12:16:06', '2025-07-21 12:25:34'),
(18, 'Nuevo acuse de recibo', 'Tienes un nuevo acuse de recibo de Hiuvert', 22, 14, 'leida', '2025-07-21 06:26:04', '2025-07-21 12:26:04', '2025-07-21 12:26:48'),
(19, 'Nuevo acuse de recibo', 'Tienes un nuevo acuse de recibo de Hiavert Yohad', 15, 15, 'leida', '2025-07-21 06:29:02', '2025-07-21 12:29:02', '2025-07-21 12:52:05'),
(22, 'Nuevo acuse de recibo', 'Tienes un nuevo acuse de recibo de Hiavert Yohad', 15, 18, 'leida', '2025-07-21 06:50:58', '2025-07-21 12:50:58', '2025-07-21 12:52:12'),
(24, 'Acuse reenviado', 'Se te ha reenviado un acuse de Hiavert Yohad', 15, 14, 'no_leida', '2025-07-21 06:59:32', '2025-07-21 12:59:32', '2025-07-21 12:59:32'),
(25, 'Nuevo acuse de recibo', 'Tienes un nuevo acuse de recibo de Hiavert Yohad', 25, 19, 'leida', '2025-07-22 05:01:31', '2025-07-22 11:01:31', '2025-07-22 11:10:00'),
(27, 'Acuse reenviado', 'Se te ha reenviado un acuse de Hiuvert', 22, 19, 'leida', '2025-07-22 05:12:50', '2025-07-22 11:12:50', '2025-07-23 04:58:35');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notifications`
--

CREATE TABLE `notifications` (
  `id` char(36) NOT NULL,
  `type` varchar(255) NOT NULL,
  `notifiable_type` varchar(255) NOT NULL,
  `notifiable_id` bigint(20) UNSIGNED NOT NULL,
  `data` text NOT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `notifications`
--

INSERT INTO `notifications` (`id`, `type`, `notifiable_type`, `notifiable_id`, `data`, `read_at`, `created_at`, `updated_at`) VALUES
('024fea94-9884-41d4-b39a-8eaa6d00e5dc', 'App\\Notifications\\NuevoProcesoTernaNotification', 'App\\Models\\User', 15, '{\"titulo\":\"Nuevo proceso de pago terna asignado\",\"mensaje\":\"Se te ha asignado un nuevo proceso: TERNA-8\",\"url\":\"http:\\/\\/127.0.0.1:8000\\/terna\\/asistente\\/8\",\"tipo\":\"nuevo-proceso-terna\"}', NULL, '2025-07-30 06:22:43', '2025-07-30 06:22:43'),
('07649f43-d375-448f-a99d-986009bfe46f', 'App\\Notifications\\NuevoProcesoTernaNotification', 'App\\Models\\User', 15, '{\"titulo\":\"Nuevo proceso de pago terna asignado\",\"mensaje\":\"Se te ha asignado un nuevo proceso: TERNA-1\",\"url\":\"http:\\/\\/127.0.0.1:8000\\/terna\\/asistente\\/1\",\"tipo\":\"nuevo-proceso-terna\"}', '2025-07-24 13:50:22', '2025-07-24 13:47:34', '2025-07-24 13:50:22'),
('17b9932d-eeec-480b-980c-20dba6684f42', 'App\\Notifications\\ProcesoCompletadoNotification', 'App\\Models\\User', 25, '{\"titulo\":\"Proceso de pago terna completado\",\"mensaje\":\"El proceso TERNA-2 ha sido completado\",\"url\":\"http:\\/\\/127.0.0.1:8000\\/terna\\/admin\\/2\",\"tipo\":\"proceso-completado-terna\"}', '2025-07-24 14:39:38', '2025-07-24 14:36:56', '2025-07-24 14:39:38'),
('1b1393a1-2503-4c99-9a17-1b2accb747d9', 'App\\Notifications\\AcuseEnviadoNotification', 'App\\Models\\User', 15, '{\"titulo\":\"Nuevo Acuse\",\"mensaje\":\"Se ha creado un nuevo acuse.\",\"nombre\":\"Hiavert Yohad\"}', '2025-07-21 12:37:36', '2025-07-21 12:29:02', '2025-07-21 12:37:36'),
('1c650ecf-b066-4e4d-826c-57906382290b', 'App\\Notifications\\TareaAsignadaNotification', 'App\\Models\\User', 24, '{\"tarea_id\":20,\"nombre\":\"imformme\",\"descripcion\":\"jgjggQ\",\"fecha_vencimiento\":\"2025-07-10\"}', NULL, '2025-07-17 04:29:10', '2025-07-17 04:29:10'),
('1c69c01e-7f5d-498d-a56a-b227d46065ee', 'App\\Notifications\\NuevoProcesoTernaNotification', 'App\\Models\\User', 15, '{\"titulo\":\"Nuevo proceso de pago terna asignado\",\"mensaje\":\"Se te ha asignado un nuevo proceso: TERNA-4\",\"url\":\"http:\\/\\/127.0.0.1:8000\\/terna\\/asistente\\/4\",\"tipo\":\"nuevo-proceso-terna\"}', '2025-07-25 02:47:42', '2025-07-24 15:55:26', '2025-07-25 02:47:42'),
('21734e8f-5db0-4ea0-b0e4-32fec921f083', 'App\\Notifications\\TareaAsignadaNotification', 'App\\Models\\User', 15, '{\"tarea_id\":17,\"nombre\":\"imformme\",\"descripcion\":\"realizar informe\",\"fecha_vencimiento\":\"2025-07-08\"}', '2025-07-08 02:25:25', '2025-07-08 02:22:26', '2025-07-08 02:25:25'),
('3abc435e-5f7e-4631-88e3-01b90daa9b69', 'App\\Notifications\\AcuseEnviadoNotification', 'App\\Models\\User', 25, '{\"titulo\":\"Nuevo Acuse\",\"mensaje\":\"Nuevo acuse de recibo.\",\"nombre\":\"Hiavert Yohad\",\"url\":\"http:\\/\\/127.0.0.1:8000\\/acuses\"}', '2025-07-22 11:10:41', '2025-07-22 11:03:01', '2025-07-22 11:10:41'),
('3c1dfde0-3e3b-47dc-942d-4b243d2c0496', 'App\\Notifications\\NuevoProcesoTernaNotification', 'App\\Models\\User', 15, '{\"titulo\":\"Nuevo proceso de pago terna asignado\",\"mensaje\":\"Se te ha asignado un nuevo proceso: TERNA-3\",\"url\":\"http:\\/\\/127.0.0.1:8000\\/terna\\/asistente\\/3\",\"tipo\":\"nuevo-proceso-terna\"}', '2025-07-25 02:47:42', '2025-07-24 15:38:14', '2025-07-25 02:47:42'),
('49aa747b-25fe-484d-a616-6ac9f178d04c', 'App\\Notifications\\ProcesoCompletadoNotification', 'App\\Models\\User', 25, '{\"titulo\":\"Proceso de pago terna completado\",\"mensaje\":\"El proceso TERNA-6 ha sido completado\",\"url\":\"http:\\/\\/127.0.0.1:8000\\/terna\\/admin\\/6\",\"tipo\":\"proceso-completado-terna\"}', '2025-07-25 04:35:21', '2025-07-25 02:47:12', '2025-07-25 04:35:21'),
('54ced72f-de35-4800-a219-6bcc235c49cc', 'App\\Notifications\\NuevoProcesoTernaNotification', 'App\\Models\\User', 15, '{\"titulo\":\"Nuevo proceso de pago terna asignado\",\"mensaje\":\"Se te ha asignado un nuevo proceso: TERNA-5\",\"url\":\"http:\\/\\/127.0.0.1:8000\\/terna\\/asistente\\/5\",\"tipo\":\"nuevo-proceso-terna\"}', '2025-07-25 02:47:42', '2025-07-25 02:04:37', '2025-07-25 02:47:42'),
('579d1617-ff57-49a8-a4cf-86afcc1b198a', 'App\\Notifications\\NuevoProcesoTernaNotification', 'App\\Models\\User', 15, '{\"titulo\":\"Nuevo proceso de pago terna asignado\",\"mensaje\":\"Se te ha asignado un nuevo proceso: TERNA-6\",\"url\":\"http:\\/\\/127.0.0.1:8000\\/terna\\/asistente\\/6\",\"tipo\":\"nuevo-proceso-terna\"}', '2025-07-25 02:47:42', '2025-07-25 02:41:08', '2025-07-25 02:47:42'),
('6089a7b0-f167-4afd-b994-b2807074b14a', 'App\\Notifications\\AcuseEnviadoNotification', 'App\\Models\\User', 25, '{\"titulo\":\"Nuevo Acuse\",\"mensaje\":\"Te han enviado un nuevo acuse de recibo.\",\"nombre\":\"Hiavert Yohad\",\"url\":\"http:\\/\\/127.0.0.1:8000\\/acuses\"}', '2025-07-21 12:39:46', '2025-07-21 12:39:25', '2025-07-21 12:39:46'),
('62a1917e-2e7d-4df3-a281-0f2f3443d249', 'App\\Notifications\\TareaAsignadaNotification', 'App\\Models\\User', 20, '{\"tarea_id\":18,\"nombre\":\"curriculum\",\"descripcion\":\"ponete vivo a revisar\",\"fecha_vencimiento\":\"2025-07-11\"}', NULL, '2025-07-08 06:20:16', '2025-07-08 06:20:16'),
('70a8edaf-af17-47f5-831d-dd04ecea7b6e', 'App\\Notifications\\ProcesoCompletadoNotification', 'App\\Models\\User', 25, '{\"titulo\":\"Proceso de pago terna completado\",\"mensaje\":\"El proceso TERNA-1 ha sido completado\",\"url\":\"http:\\/\\/127.0.0.1:8000\\/terna\\/admin\\/1\",\"tipo\":\"proceso-completado-terna\"}', '2025-07-24 13:56:02', '2025-07-24 13:54:23', '2025-07-24 13:56:02'),
('744732e9-2f8f-4387-aea4-00d684a6110a', 'App\\Notifications\\TareaAsignadaNotification', 'App\\Models\\User', 21, '{\"tarea_id\":16,\"nombre\":\"revisa documentos del docente Juan\",\"descripcion\":\"revisa\",\"fecha_vencimiento\":\"2025-07-13\"}', NULL, '2025-07-04 02:28:14', '2025-07-04 02:28:14'),
('898c6447-ac65-4321-8509-6365f99eac40', 'App\\Notifications\\ProcesoCompletadoNotification', 'App\\Models\\User', 25, '{\"titulo\":\"Proceso de pago terna completado\",\"mensaje\":\"El proceso TERNA-8 ha sido completado\",\"url\":\"http:\\/\\/127.0.0.1:8000\\/terna\\/admin\\/8\",\"tipo\":\"proceso-completado-terna\"}', NULL, '2025-07-30 06:45:35', '2025-07-30 06:45:35'),
('919a4ebc-3956-427c-b8e6-29962a2e24eb', 'App\\Notifications\\TareaAsignadaNotification', 'App\\Models\\User', 26, '{\"tarea_id\":22,\"nombre\":\"i0ojoinio\",\"descripcion\":\"ionionio\",\"fecha_vencimiento\":\"2025-07-22\"}', NULL, '2025-07-22 11:15:40', '2025-07-22 11:15:40'),
('abfa10e0-61f8-4cbb-a252-58c664884c25', 'App\\Notifications\\TareaAsignadaNotification', 'App\\Models\\User', 20, '{\"tarea_id\":19,\"nombre\":\"curriculum\",\"descripcion\":\"ponete vivo a revisar\",\"fecha_vencimiento\":\"2025-07-11\"}', NULL, '2025-07-08 06:20:20', '2025-07-08 06:20:20'),
('ca39d18e-2bc4-4d9b-b258-2437c3a06f8c', 'App\\Notifications\\AcuseEnviadoNotification', 'App\\Models\\User', 15, '{\"titulo\":\"Nuevo Acuse\",\"mensaje\":\"Nuevo acuse de recibo de: \",\"nombre\":\"Hiavert Yohad\",\"url\":\"http:\\/\\/127.0.0.1:8000\\/acuses\"}', '2025-07-21 12:52:02', '2025-07-21 12:50:58', '2025-07-21 12:52:02'),
('cfbcafad-1c77-4b41-8a45-0e916a0a5d0e', 'App\\Notifications\\TareaAsignadaNotification', 'App\\Models\\User', 22, '{\"tarea_id\":21,\"nombre\":\"curriculum\",\"descripcion\":\"ioshgiogh\",\"fecha_vencimiento\":\"2025-07-11\"}', '2025-07-17 04:33:06', '2025-07-17 04:29:46', '2025-07-17 04:33:06'),
('dbe12e10-e2b9-427f-960b-5e03090490d0', 'App\\Notifications\\AcuseEnviadoNotification', 'App\\Models\\User', 25, '{\"titulo\":\"Nuevo Acuse\",\"mensaje\":\"Nuevo acuse de recibo.\",\"nombre\":\"Hiavert Yohad\",\"url\":\"http:\\/\\/127.0.0.1:8000\\/acuses\"}', '2025-07-22 11:10:41', '2025-07-22 11:01:33', '2025-07-22 11:10:41'),
('dd8f18e3-c3eb-43de-b986-ea9e2aaa787e', 'App\\Notifications\\TareaAsignadaNotification', 'App\\Models\\User', 25, '{\"tarea_id\":23,\"nombre\":\"Expediente de ingreso\",\"descripcion\":\"Urgente\",\"fecha_vencimiento\":\"2025-08-07\"}', NULL, '2025-07-30 06:57:19', '2025-07-30 06:57:19'),
('e6251136-90ad-4382-ac3b-e075743ca96a', 'App\\Notifications\\NuevoProcesoTernaNotification', 'App\\Models\\User', 15, '{\"titulo\":\"Nuevo proceso de pago terna asignado\",\"mensaje\":\"Se te ha asignado un nuevo proceso: TERNA-2\",\"url\":\"http:\\/\\/127.0.0.1:8000\\/terna\\/asistente\\/2\",\"tipo\":\"nuevo-proceso-terna\"}', '2025-07-24 14:29:03', '2025-07-24 14:28:13', '2025-07-24 14:29:03'),
('e63fc7ed-ae13-4272-be53-a2cc3ffa12f6', 'App\\Notifications\\AcuseEnviadoNotification', 'App\\Models\\User', 22, '{\"titulo\":\"Nuevo Acuse\",\"mensaje\":\"Se ha creado un nuevo acuse.\",\"nombre\":\"Hiuvert\"}', '2025-07-21 12:26:42', '2025-07-21 12:26:04', '2025-07-21 12:26:42'),
('f5846b4b-3cda-4e3e-9ff3-3b75e97411f3', 'App\\Notifications\\NuevoProcesoTernaNotification', 'App\\Models\\User', 15, '{\"titulo\":\"Nuevo proceso de pago terna asignado\",\"mensaje\":\"Se te ha asignado un nuevo proceso: TERNA-7\",\"url\":\"http:\\/\\/127.0.0.1:8000\\/terna\\/asistente\\/7\",\"tipo\":\"nuevo-proceso-terna\"}', '2025-07-30 00:50:17', '2025-07-30 00:47:39', '2025-07-30 00:50:17'),
('fa54c891-f82b-404e-a69e-8e392198b32a', 'App\\Notifications\\AcuseEnviadoNotification', 'App\\Models\\User', 15, '{\"titulo\":\"Nuevo Acuse\",\"mensaje\":\"Te han enviado un nuevo acuse de recibo.\",\"nombre\":\"Hiuvert\",\"url\":\"http:\\/\\/127.0.0.1:8000\\/acuses\"}', '2025-07-21 12:47:27', '2025-07-21 12:45:59', '2025-07-21 12:47:27');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `objetos`
--

CREATE TABLE `objetos` (
  `id_objeto` bigint(20) NOT NULL,
  `nombre_objeto` varchar(100) NOT NULL,
  `tipo_objeto` enum('Módulo','Función','Reporte') NOT NULL,
  `descripcion_objeto` varchar(255) DEFAULT NULL,
  `estado_objeto` enum('0','1') DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `objetos`
--

INSERT INTO `objetos` (`id_objeto`, `nombre_objeto`, `tipo_objeto`, `descripcion_objeto`, `estado_objeto`, `created_at`, `updated_at`) VALUES
(3, 'dashboard', 'Módulo', 'Panel principal', '1', '2025-06-25 14:30:56', '2025-06-25 14:30:56'),
(4, 'Terna', 'Módulo', 'Gestión de pagos de terna', '1', '2025-06-25 14:30:56', '2025-06-25 14:30:56'),
(5, 'TareasDocumentales', 'Módulo', 'Gestión de tareas documentales', '1', '2025-06-25 14:30:56', '2025-06-25 14:30:56'),
(7, 'Usuarios', 'Módulo', 'Gestión de usuarios', '1', '2025-06-25 14:30:56', '2025-06-25 14:30:56'),
(8, 'Roles', 'Módulo', 'Gestión de roles y permisos', '1', '2025-06-25 14:30:56', '2025-06-25 14:30:56'),
(9, 'Reportes', 'Reporte', 'Generación de reportes', '1', '2025-06-25 14:30:56', '2025-06-25 14:30:56'),
(11, 'Bitacora', 'Módulo', 'Vista general de todos los cambios que se realizan.', '1', '2025-06-25 16:16:01', '2025-07-02 03:15:49'),
(12, 'GestionAcuses', 'Módulo', 'Gestion de acuses de recibo', '1', '2025-07-07 06:53:28', '2025-07-07 06:53:28'),
(13, 'GestionTesis', 'Módulo', 'Gestión Documental de Tesis', '1', '2025-07-07 07:59:18', '2025-07-07 07:59:18'),
(14, 'GestorRendimiento', 'Módulo', 'Graficos de terna y tareas', '1', '2025-07-16 21:32:41', '2025-07-16 21:32:41'),
(16, 'Perfil', 'Módulo', 'Gestión de perfiles de usuario', '1', '2025-07-19 20:19:43', '2025-07-19 20:20:06'),
(17, 'TernaAux', 'Módulo', 'Modulo de Asistente de Terna', '1', '2025-07-24 07:53:11', '2025-07-24 07:53:11'),
(18, 'Documentos', 'Módulo', 'Modulo de documentos para secretaria', '1', '2025-07-28 21:27:28', '2025-07-28 21:27:28'),
(19, 'Recepcion', 'Módulo', 'Modulo de recepcion de archivos para usuarios', '1', '2025-07-28 21:28:06', '2025-07-28 21:28:06');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pagos_terna`
--

CREATE TABLE `pagos_terna` (
  `id` bigint(20) NOT NULL,
  `codigo` varchar(255) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `estado` enum('iniciado','en_revision','pendiente_pago','pagado','cancelado') DEFAULT 'iniciado',
  `fecha_defensa` date DEFAULT NULL,
  `fecha_limite` datetime DEFAULT NULL,
  `fecha_envio_admin` datetime DEFAULT NULL,
  `fecha_envio_asistente` datetime DEFAULT NULL,
  `fecha_pago` datetime DEFAULT NULL,
  `id_administrador` int(11) DEFAULT NULL,
  `id_asistente` int(11) DEFAULT NULL,
  `responsable` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `pagos_terna`
--

INSERT INTO `pagos_terna` (`id`, `codigo`, `descripcion`, `estado`, `fecha_defensa`, `fecha_limite`, `fecha_envio_admin`, `fecha_envio_asistente`, `fecha_pago`, `id_administrador`, `id_asistente`, `responsable`, `created_at`, `updated_at`) VALUES
(1, 'TERNA-1', 'Pago Master', 'pagado', '2025-07-17', '2025-07-25 06:00:00', '2025-07-24 07:47:32', '2025-07-24 07:54:23', '2025-07-24 07:56:19', 25, 15, 'Lic Hiavert', '2025-07-24 13:47:31', '2025-07-24 13:56:19'),
(2, 'TERNA-2', 'Pago Master Floo', 'pendiente_pago', '2025-07-02', '2025-07-30 05:30:00', '2025-07-24 08:28:13', '2025-07-24 08:36:56', NULL, 25, 15, 'Lic Hiavert', '2025-07-24 14:28:13', '2025-07-24 14:36:56'),
(3, 'TERNA-3', 'Pago Master Floo lol', 'en_revision', '2025-07-16', '2025-07-11 06:40:00', '2025-07-24 09:38:10', NULL, NULL, 25, 15, 'Lic carverucles', '2025-07-24 15:38:10', '2025-07-24 15:38:10'),
(4, 'TERNA-4', 'pecuarto', 'en_revision', '2025-07-09', '2025-07-25 01:57:00', '2025-07-24 09:55:26', NULL, NULL, 25, 15, 'yagermaister', '2025-07-24 15:55:26', '2025-07-24 15:55:26'),
(5, 'TERNA-5', 'Pago Masterlolll', 'en_revision', '2025-07-17', '2025-07-31 18:05:00', '2025-07-24 20:04:34', NULL, NULL, 25, 15, 'Lic Yarber', '2025-07-25 02:04:34', '2025-07-25 02:04:34'),
(6, 'TERNA-6', 'pecuarto', 'pagado', '2025-07-15', '2025-07-25 16:45:00', '2025-07-24 20:41:08', '2025-07-24 20:47:12', '2025-07-24 20:59:37', 25, 15, 'Lic Yanopuedomas', '2025-07-25 02:41:08', '2025-07-25 02:59:37'),
(7, 'TERNA-7', 'hola mundo', 'en_revision', '2025-07-23', '2025-07-30 16:50:00', '2025-07-29 18:47:37', NULL, NULL, 25, 15, 'Lic Musculoso', '2025-07-30 00:47:36', '2025-07-30 00:47:37'),
(8, 'TERNA-8', 'Pago Masterrr', 'pagado', '2025-07-14', '2025-08-10 20:20:00', '2025-07-30 00:22:40', '2025-07-30 00:45:35', '2025-07-30 00:46:46', 25, 15, 'Ramon Osorio', '2025-07-30 06:22:39', '2025-07-30 06:46:46');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `password_resets`
--

CREATE TABLE `password_resets` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `password_resets`
--

INSERT INTO `password_resets` (`id`, `email`, `token`, `created_at`, `updated_at`) VALUES
(27, 'ucleshiaverth@gmail.com', '$2y$12$WcSRWGSPRd75Afn9o9FKF.nD/7AACObkuKpKa5Vc0.alYGIX8ytRG', '2025-07-07 09:22:51', NULL),
(28, 'lfiallos@appteck.com', '$2y$12$9A5k80rDsyJs36BKP.EofOygyrd5/aNBxhVzuvXHGkBZ5ljVvz0q.', '2025-07-08 06:27:19', NULL),
(30, 'ramon.a.osorio.r86@gmail.com', '$2y$12$xLAuk4u3Jl1KWy28gaMB.ewTP4CYb7Ncp78I8eR8UwUNYyPa8QV6.', '2025-07-22 10:40:45', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personas`
--

CREATE TABLE `personas` (
  `id_persona` int(11) NOT NULL,
  `nombres` varchar(100) NOT NULL,
  `apellidos` varchar(100) NOT NULL,
  `cedula` varchar(20) NOT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `posface`
--

CREATE TABLE `posface` (
  `id_empresa` int(11) NOT NULL,
  `nombre_empresa` varchar(100) NOT NULL,
  `direccion_empresa` varchar(200) NOT NULL,
  `telefono_empresa` varchar(20) DEFAULT NULL,
  `ruc` varchar(50) NOT NULL,
  `fecha_fundacion` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `regiones`
--

CREATE TABLE `regiones` (
  `id_region` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `regiones`
--

INSERT INTO `regiones` (`id_region`, `nombre`, `created_at`, `updated_at`) VALUES
(1, 'Atlántida', '2025-07-04 22:09:34', '2025-07-04 22:09:34'),
(2, 'Choluteca', '2025-07-04 22:09:34', '2025-07-04 22:09:34'),
(3, 'Colón', '2025-07-04 22:09:34', '2025-07-04 22:09:34'),
(4, 'Comayagua', '2025-07-04 22:09:34', '2025-07-04 22:09:34'),
(5, 'Copán', '2025-07-04 22:09:34', '2025-07-04 22:09:34'),
(6, 'Cortés', '2025-07-04 22:09:34', '2025-07-04 22:09:34'),
(7, 'El Paraíso', '2025-07-04 22:09:34', '2025-07-04 22:09:34'),
(8, 'Francisco Morazán', '2025-07-04 22:09:34', '2025-07-04 22:09:34'),
(9, 'Gracias a Dios', '2025-07-04 22:09:34', '2025-07-04 22:09:34'),
(10, 'Intibucá', '2025-07-04 22:09:34', '2025-07-04 22:09:34'),
(11, 'Islas de la Bahía', '2025-07-04 22:09:34', '2025-07-04 22:09:34'),
(12, 'La Paz', '2025-07-04 22:09:34', '2025-07-04 22:09:34'),
(13, 'Lempira', '2025-07-04 22:09:34', '2025-07-04 22:09:34'),
(14, 'Ocotepeque', '2025-07-04 22:09:34', '2025-07-04 22:09:34'),
(15, 'Olancho', '2025-07-04 22:09:34', '2025-07-04 22:09:34'),
(16, 'Santa Bárbara', '2025-07-04 22:09:34', '2025-07-04 22:09:34'),
(17, 'Valle', '2025-07-04 22:09:34', '2025-07-04 22:09:34'),
(18, 'Yoro', '2025-07-04 22:09:34', '2025-07-04 22:09:34');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reporte_expediente`
--

CREATE TABLE `reporte_expediente` (
  `id_reporte` int(11) NOT NULL,
  `nombre_reporte` varchar(100) NOT NULL,
  `tipo_reporte` enum('Terna','Tesis','Docente','Estudiantil') NOT NULL,
  `fecha_generacion` date NOT NULL,
  `detalles` text DEFAULT NULL,
  `ruta_archivo` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles`
--

CREATE TABLE `roles` (
  `id_rol` bigint(20) NOT NULL,
  `nombre_rol` varchar(100) NOT NULL,
  `descripcion_rol` varchar(255) DEFAULT NULL,
  `estado_rol` enum('0','1') DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `roles`
--

INSERT INTO `roles` (`id_rol`, `nombre_rol`, `descripcion_rol`, `estado_rol`, `created_at`, `updated_at`) VALUES
(1, 'Administrador', 'administra', '1', '2025-06-24 16:29:46', '2025-07-02 23:19:10'),
(2, 'vendedor', 'el que vende', '1', '2025-06-25 08:25:19', '2025-07-07 09:16:13'),
(3, 'SuperAdmin', 'super usuario', '1', '2025-06-25 22:06:34', '2025-07-03 20:08:51'),
(5, 'docente', 'docentar', '1', '2025-07-08 01:40:48', '2025-07-08 01:40:48'),
(6, 'Asistente de Terna', 'Realiza seguimiento de Pagos terna', '1', '2025-07-22 03:18:37', '2025-07-22 03:18:37'),
(7, 'Administrador de Terna', 'Inicia el proceso de pago terna', '1', '2025-07-22 03:21:22', '2025-07-22 03:21:22');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('lFXBOuJQp5IucFcUMJXCGKsEJmfVRzaXHUzt00sN', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUnVva0c5VmdIUHFtUnJZd1FKdEFvNlhNTVhac2xIQ2licVRKUVhpSiI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMCI7fX0=', 1753839224);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tareas`
--

CREATE TABLE `tareas` (
  `id_tarea` int(11) NOT NULL,
  `fk_id_usuario_asignado` int(11) NOT NULL,
  `fk_id_usuario_creador` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `estado` varchar(50) NOT NULL,
  `fecha_creacion` date NOT NULL,
  `fecha_vencimiento` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tareas`
--

INSERT INTO `tareas` (`id_tarea`, `fk_id_usuario_asignado`, `fk_id_usuario_creador`, `nombre`, `descripcion`, `estado`, `fecha_creacion`, `fecha_vencimiento`, `created_at`, `updated_at`, `deleted_at`) VALUES
(17, 15, 22, 'imformme', 'realizar informe', 'Completada', '2025-07-07', NULL, '2025-07-08 02:22:08', '2025-07-30 07:02:12', '2025-07-30 07:02:12'),
(18, 20, 22, 'curriculum', 'ponete vivo a revisar', 'Completada', '2025-07-08', NULL, '2025-07-08 06:19:57', '2025-07-21 09:05:53', NULL),
(19, 20, 25, 'curriculum', 'ponete vivo a revisar', 'En Proceso', '2025-07-08', NULL, '2025-07-08 06:20:17', '2025-07-22 11:17:06', NULL),
(20, 24, 22, 'imformme', 'jgjggQ', 'Completada', '2025-07-09', NULL, '2025-07-17 04:28:51', '2025-07-21 10:51:15', NULL),
(21, 22, 25, 'curriculum', 'ioshgiogh', 'Pendiente', '2025-07-09', NULL, '2025-07-17 04:29:44', '2025-07-22 11:16:51', NULL),
(22, 26, 25, 'i0ojoinio', 'ionionio', 'En Proceso', '2025-07-22', NULL, '2025-07-22 11:15:24', '2025-07-22 11:16:26', NULL),
(23, 26, 22, 'Expediente de ingreso', 'Urgente', 'Pendiente', '2025-07-29', NULL, '2025-07-30 06:57:03', '2025-07-30 07:05:12', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tarea_documento`
--

CREATE TABLE `tarea_documento` (
  `id_tarea_documento` int(11) NOT NULL,
  `fk_id_tarea` int(11) NOT NULL,
  `fk_id_documento` int(11) DEFAULT NULL,
  `fk_id_tesis` int(11) DEFAULT NULL,
  `fecha_asociacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `observaciones` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tarea_documento`
--

INSERT INTO `tarea_documento` (`id_tarea_documento`, `fk_id_tarea`, `fk_id_documento`, `fk_id_tesis`, `fecha_asociacion`, `observaciones`) VALUES
(2, 18, 6, NULL, '2025-07-08 06:20:48', NULL),
(3, 18, 7, NULL, '2025-07-08 06:21:10', NULL),
(4, 23, 8, NULL, '2025-07-30 06:59:08', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tesis`
--

CREATE TABLE `tesis` (
  `id_tesis` int(11) NOT NULL,
  `fk_id_usuario` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `autor` varchar(100) NOT NULL,
  `numero_cuenta` varchar(20) NOT NULL,
  `carrera` varchar(100) NOT NULL DEFAULT 'No especificado',
  `tema` varchar(255) NOT NULL DEFAULT 'No especificado',
  `anio` year(4) NOT NULL,
  `fecha_subida` date DEFAULT NULL,
  `ruta_archivo` varchar(255) NOT NULL,
  `fecha_defensa` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  `fk_id_tipo_tesis` int(11) DEFAULT NULL,
  `fk_id_region` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tesis`
--

INSERT INTO `tesis` (`id_tesis`, `fk_id_usuario`, `titulo`, `autor`, `numero_cuenta`, `carrera`, `tema`, `anio`, `fecha_subida`, `ruta_archivo`, `fecha_defensa`, `created_at`, `updated_at`, `deleted_at`, `fk_id_tipo_tesis`, `fk_id_region`) VALUES
(25, 25, 'always', 'carver', '20191003639', 'No especificado', 'No especificado', '2025', '2025-07-20', 'tesis_1752998459.pdf', '2025-07-29', '2025-07-20 14:00:59', '2025-07-20 14:00:59', NULL, 2, 11),
(26, 25, 'experimento social', 'ismary', '20201003684', 'No especificado', 'No especificado', '2025', '2025-07-20', 'tesis_1753000207.pdf', '2025-07-02', '2025-07-20 14:30:07', '2025-07-20 14:30:07', NULL, 4, 8);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipos_elemento`
--

CREATE TABLE `tipos_elemento` (
  `id_tipo` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `categoria` enum('documento','objeto','kit') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipos_elemento`
--

INSERT INTO `tipos_elemento` (`id_tipo`, `nombre`, `categoria`, `created_at`, `updated_at`) VALUES
(1, 'Documentacion de tesis', 'documento', '2025-07-05 10:01:53', '2025-07-05 10:01:53'),
(2, 'Figura de accion', 'objeto', '2025-07-05 10:10:45', '2025-07-05 10:10:45'),
(3, 'Lapices Sharpie', 'kit', '2025-07-05 10:25:29', '2025-07-05 10:25:29'),
(4, 'Expediente', 'documento', '2025-07-21 11:21:44', '2025-07-21 11:21:44');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipos_tesis`
--

CREATE TABLE `tipos_tesis` (
  `id_tipo_tesis` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipos_tesis`
--

INSERT INTO `tipos_tesis` (`id_tipo_tesis`, `nombre`, `created_at`, `updated_at`) VALUES
(1, 'Maestría', '2025-07-04 22:08:41', '2025-07-04 22:08:41'),
(2, 'Doctorado', '2025-07-04 22:08:41', '2025-07-04 22:08:41'),
(3, 'Especialización', '2025-07-04 22:08:41', '2025-07-04 22:08:41'),
(4, 'Investigación Aplicada', '2025-07-04 22:08:41', '2025-07-04 22:08:41');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_documento`
--

CREATE TABLE `tipo_documento` (
  `id_tipo` int(10) UNSIGNED NOT NULL,
  `nombre_tipo` varchar(100) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `tipo_documento`
--

INSERT INTO `tipo_documento` (`id_tipo`, `nombre_tipo`, `descripcion`, `created_at`, `updated_at`) VALUES
(1, 'RTN', 'RTN del docente', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL,
  `nombres` varchar(100) DEFAULT NULL,
  `apellidos` varchar(100) DEFAULT NULL,
  `usuario` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `identidad` varchar(20) DEFAULT NULL,
  `estado` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  `usr_add` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_usuario`, `nombres`, `apellidos`, `usuario`, `password`, `email`, `identidad`, `estado`, `created_at`, `updated_at`, `deleted_at`, `usr_add`) VALUES
(15, 'Usuario', 'Admin', 'Usuario-Ejemplo', '$2y$12$nKFZ0/eMziAPewlNKt06POS68A7DJTOOr47T8LD/oSLB/Cb8ijvg2', 'admin@unah.edu.hn', '13224214', 1, '2025-06-25 07:15:30', '2025-07-03 19:43:07', NULL, NULL),
(20, 'Hola', 'Mundo', 'Usuario-Prueba', '$2y$12$ewsSXM327DLIFunL/YjvYOJkhecRPqOWWtqIAYIwusPTCgX6p4tKq', 'example@unah.edu.hn', '876843', 1, '2025-07-02 07:19:51', '2025-07-03 19:42:08', NULL, NULL),
(22, 'Hiavert Yohad', 'Maldonado Ucles', 'Hiavert-MU', '$2y$12$YkOwaQ2rMQDHIugr1QVmO.2s8zHpBYTlbPFOAQ6atnxKXW4DE9wje', 'ucleshiaverth@gmail.com', '0801200015479', 1, '2025-07-05 09:59:52', '2025-07-05 10:00:36', NULL, NULL),
(23, 'tati', 'avila', 'papazombi-Z', '$2y$12$qxzLnpgk4kr5EQZ/6J3gqeLRhyG2hw6WCNpR67Zo6fobSMW3xLn8e', 'papazombi771@gmail.com', '090910101011', 1, '2025-07-05 10:39:39', '2025-07-08 04:07:38', '2025-07-08 04:07:38', NULL),
(24, 'lester', 'fiallos', 'lester-F', '$2y$12$MyPLpDYJqgXge9D22s0KzuhfNH8ISyJXBCEn65Ulaa6Y.qYHhAgHy', 'lfiallos@appteck.com', '080120001547', 1, '2025-07-08 06:27:19', '2025-07-08 06:27:19', NULL, NULL),
(25, 'Hiuvert', 'Maldonado', 'Hiuvert-M', '$2y$12$BkCKDtzzqIPzOfPser3wwOArRG7zkCJVTQyRbwCMOT9xmqcU4Zkgy', 'hiavert.maldonado@unah.hn', '0801198005264', 1, '2025-07-20 11:31:28', '2025-07-20 11:32:42', NULL, NULL),
(26, 'Ramon', 'Osorio', 'Ramon-O', '$2y$12$ifxIldZWVGSxT4iymZQ65eY/szWeoC4uG6yO6zW0GLSNG4zM3Meu6', 'ramon.a.osorio.r86@gmail.com', '0801199910636', 1, '2025-07-22 10:40:44', '2025-07-22 10:40:44', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario_roles`
--

CREATE TABLE `usuario_roles` (
  `id_usuario_rol` bigint(20) NOT NULL,
  `fk_id_usuario` int(11) NOT NULL,
  `fk_id_rol` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario_roles`
--

INSERT INTO `usuario_roles` (`id_usuario_rol`, `fk_id_usuario`, `fk_id_rol`, `created_at`, `updated_at`) VALUES
(20, 20, 1, '2025-07-02 03:36:04', '2025-07-02 03:36:04'),
(22, 22, 3, '2025-07-05 03:59:52', '2025-07-05 03:59:52'),
(33, 24, 5, '2025-07-08 00:27:19', '2025-07-08 00:27:19'),
(41, 26, 3, '2025-07-22 04:40:44', '2025-07-22 04:40:44'),
(46, 15, 6, '2025-07-22 08:32:49', '2025-07-22 08:32:49'),
(47, 25, 7, '2025-07-22 08:49:59', '2025-07-22 08:49:59');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `accesos`
--
ALTER TABLE `accesos`
  ADD PRIMARY KEY (`id_acceso`),
  ADD KEY `fk_accesos_rol` (`fk_id_rol`),
  ADD KEY `fk_accesos_objeto` (`fk_id_objeto`);

--
-- Indices de la tabla `acuses`
--
ALTER TABLE `acuses`
  ADD PRIMARY KEY (`id_acuse`),
  ADD KEY `fk_id_usuario_remitente` (`fk_id_usuario_remitente`),
  ADD KEY `fk_id_usuario_destinatario` (`fk_id_usuario_destinatario`),
  ADD KEY `fk_id_acuse_original` (`fk_id_acuse_original`);

--
-- Indices de la tabla `acuses_adjuntos`
--
ALTER TABLE `acuses_adjuntos`
  ADD PRIMARY KEY (`id_adjunto`),
  ADD KEY `fk_id_acuse` (`fk_id_acuse`);

--
-- Indices de la tabla `acuses_transferencias`
--
ALTER TABLE `acuses_transferencias`
  ADD PRIMARY KEY (`id_transferencia`),
  ADD KEY `fk_id_acuse` (`fk_id_acuse`),
  ADD KEY `fk_id_usuario_origen` (`fk_id_usuario_origen`),
  ADD KEY `fk_id_usuario_destino` (`fk_id_usuario_destino`);

--
-- Indices de la tabla `auditoria`
--
ALTER TABLE `auditoria`
  ADD PRIMARY KEY (`id_auditoria`),
  ADD KEY `fk_auditoria_usuario` (`fk_id_usuario`);

--
-- Indices de la tabla `bitacoras`
--
ALTER TABLE `bitacoras`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indices de la tabla `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indices de la tabla `documentos`
--
ALTER TABLE `documentos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `documentos_user_id_foreign` (`user_id`);

--
-- Indices de la tabla `documentos_terna`
--
ALTER TABLE `documentos_terna`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pago_terna_id` (`pago_terna_id`);

--
-- Indices de la tabla `documento_administrativo`
--
ALTER TABLE `documento_administrativo`
  ADD PRIMARY KEY (`id_documento`),
  ADD KEY `fk_documento_usuario` (`fk_id_usuario`),
  ADD KEY `idx_documento_nombre` (`nombre_documento`),
  ADD KEY `documento_administrativo_fk_id_tipo_foreign` (`fk_id_tipo`);

--
-- Indices de la tabla `documento_envios`
--
ALTER TABLE `documento_envios`
  ADD PRIMARY KEY (`id`),
  ADD KEY `documento_envios_documento_id_foreign` (`documento_id`),
  ADD KEY `documento_envios_user_id_foreign` (`user_id`),
  ADD KEY `documento_envios_enviado_por_foreign` (`enviado_por`);

--
-- Indices de la tabla `elementos`
--
ALTER TABLE `elementos`
  ADD PRIMARY KEY (`id_elemento`),
  ADD KEY `fk_id_tipo` (`fk_id_tipo`),
  ADD KEY `fk_id_acuse` (`fk_id_acuse`);

--
-- Indices de la tabla `estado_documento`
--
ALTER TABLE `estado_documento`
  ADD PRIMARY KEY (`id_estado`);

--
-- Indices de la tabla `estado_pago`
--
ALTER TABLE `estado_pago`
  ADD PRIMARY KEY (`id_estado_pago`);

--
-- Indices de la tabla `expediente_docente`
--
ALTER TABLE `expediente_docente`
  ADD PRIMARY KEY (`id_expediente_docente`),
  ADD KEY `fk_expediente_docente_persona` (`fk_id_persona`);

--
-- Indices de la tabla `expediente_estudiantil`
--
ALTER TABLE `expediente_estudiantil`
  ADD PRIMARY KEY (`id_expediente_estudiantil`),
  ADD KEY `fk_expediente_estudiantil_persona` (`fk_id_persona`);

--
-- Indices de la tabla `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indices de la tabla `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indices de la tabla `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `log_login`
--
ALTER TABLE `log_login`
  ADD PRIMARY KEY (`id_log`),
  ADD KEY `fk_login_usuario` (`fk_id_usuario`);

--
-- Indices de la tabla `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD PRIMARY KEY (`id_notificacion`),
  ADD KEY `fk_id_usuario_destinatario` (`fk_id_usuario_destinatario`),
  ADD KEY `fk_id_acuse` (`fk_id_acuse`);

--
-- Indices de la tabla `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `notifications_notifiable_type_notifiable_id_index` (`notifiable_type`,`notifiable_id`);

--
-- Indices de la tabla `objetos`
--
ALTER TABLE `objetos`
  ADD PRIMARY KEY (`id_objeto`),
  ADD UNIQUE KEY `nombre_objeto` (`nombre_objeto`);

--
-- Indices de la tabla `pagos_terna`
--
ALTER TABLE `pagos_terna`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo` (`codigo`),
  ADD KEY `id_administrador` (`id_administrador`),
  ADD KEY `id_asistente` (`id_asistente`);

--
-- Indices de la tabla `password_resets`
--
ALTER TABLE `password_resets`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `personas`
--
ALTER TABLE `personas`
  ADD PRIMARY KEY (`id_persona`),
  ADD UNIQUE KEY `cedula` (`cedula`);

--
-- Indices de la tabla `posface`
--
ALTER TABLE `posface`
  ADD PRIMARY KEY (`id_empresa`),
  ADD UNIQUE KEY `ruc` (`ruc`);

--
-- Indices de la tabla `regiones`
--
ALTER TABLE `regiones`
  ADD PRIMARY KEY (`id_region`);

--
-- Indices de la tabla `reporte_expediente`
--
ALTER TABLE `reporte_expediente`
  ADD PRIMARY KEY (`id_reporte`);

--
-- Indices de la tabla `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id_rol`),
  ADD UNIQUE KEY `nombre_rol` (`nombre_rol`);

--
-- Indices de la tabla `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indices de la tabla `tareas`
--
ALTER TABLE `tareas`
  ADD PRIMARY KEY (`id_tarea`),
  ADD KEY `fk_tarea_usuario_asignado` (`fk_id_usuario_asignado`),
  ADD KEY `fk_tarea_usuario_creador` (`fk_id_usuario_creador`),
  ADD KEY `idx_tarea_estado` (`estado`);

--
-- Indices de la tabla `tarea_documento`
--
ALTER TABLE `tarea_documento`
  ADD PRIMARY KEY (`id_tarea_documento`),
  ADD KEY `fk_tarea_documento_tarea` (`fk_id_tarea`),
  ADD KEY `fk_tarea_documento_documento` (`fk_id_documento`),
  ADD KEY `fk_tarea_documento_tesis` (`fk_id_tesis`);

--
-- Indices de la tabla `tesis`
--
ALTER TABLE `tesis`
  ADD PRIMARY KEY (`id_tesis`),
  ADD KEY `fk_tesis_usuario` (`fk_id_usuario`),
  ADD KEY `idx_tesis_titulo` (`titulo`),
  ADD KEY `fk_tesis_tipo` (`fk_id_tipo_tesis`),
  ADD KEY `fk_tesis_region` (`fk_id_region`);

--
-- Indices de la tabla `tipos_elemento`
--
ALTER TABLE `tipos_elemento`
  ADD PRIMARY KEY (`id_tipo`);

--
-- Indices de la tabla `tipos_tesis`
--
ALTER TABLE `tipos_tesis`
  ADD PRIMARY KEY (`id_tipo_tesis`);

--
-- Indices de la tabla `tipo_documento`
--
ALTER TABLE `tipo_documento`
  ADD PRIMARY KEY (`id_tipo`),
  ADD UNIQUE KEY `tipo_documento_nombre_tipo_unique` (`nombre_tipo`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `usuario` (`usuario`),
  ADD UNIQUE KEY `correo` (`email`),
  ADD UNIQUE KEY `identidad` (`identidad`),
  ADD KEY `fk_usuario_add` (`usr_add`),
  ADD KEY `idx_usuario_correo` (`email`);

--
-- Indices de la tabla `usuario_roles`
--
ALTER TABLE `usuario_roles`
  ADD PRIMARY KEY (`id_usuario_rol`),
  ADD KEY `fk_usuario_rol_usuario` (`fk_id_usuario`),
  ADD KEY `fk_usuario_rol_rol` (`fk_id_rol`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `accesos`
--
ALTER TABLE `accesos`
  MODIFY `id_acceso` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=198;

--
-- AUTO_INCREMENT de la tabla `acuses`
--
ALTER TABLE `acuses`
  MODIFY `id_acuse` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de la tabla `acuses_adjuntos`
--
ALTER TABLE `acuses_adjuntos`
  MODIFY `id_adjunto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `acuses_transferencias`
--
ALTER TABLE `acuses_transferencias`
  MODIFY `id_transferencia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `auditoria`
--
ALTER TABLE `auditoria`
  MODIFY `id_auditoria` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `bitacoras`
--
ALTER TABLE `bitacoras`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=113;

--
-- AUTO_INCREMENT de la tabla `documentos`
--
ALTER TABLE `documentos`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `documentos_terna`
--
ALTER TABLE `documentos_terna`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT de la tabla `documento_administrativo`
--
ALTER TABLE `documento_administrativo`
  MODIFY `id_documento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `documento_envios`
--
ALTER TABLE `documento_envios`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `elementos`
--
ALTER TABLE `elementos`
  MODIFY `id_elemento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de la tabla `estado_documento`
--
ALTER TABLE `estado_documento`
  MODIFY `id_estado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `estado_pago`
--
ALTER TABLE `estado_pago`
  MODIFY `id_estado_pago` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `expediente_docente`
--
ALTER TABLE `expediente_docente`
  MODIFY `id_expediente_docente` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `expediente_estudiantil`
--
ALTER TABLE `expediente_estudiantil`
  MODIFY `id_expediente_estudiantil` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `log_login`
--
ALTER TABLE `log_login`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  MODIFY `id_notificacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT de la tabla `objetos`
--
ALTER TABLE `objetos`
  MODIFY `id_objeto` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT de la tabla `pagos_terna`
--
ALTER TABLE `pagos_terna`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `password_resets`
--
ALTER TABLE `password_resets`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `personas`
--
ALTER TABLE `personas`
  MODIFY `id_persona` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `posface`
--
ALTER TABLE `posface`
  MODIFY `id_empresa` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `regiones`
--
ALTER TABLE `regiones`
  MODIFY `id_region` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT de la tabla `reporte_expediente`
--
ALTER TABLE `reporte_expediente`
  MODIFY `id_reporte` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `roles`
--
ALTER TABLE `roles`
  MODIFY `id_rol` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `tareas`
--
ALTER TABLE `tareas`
  MODIFY `id_tarea` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT de la tabla `tarea_documento`
--
ALTER TABLE `tarea_documento`
  MODIFY `id_tarea_documento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `tesis`
--
ALTER TABLE `tesis`
  MODIFY `id_tesis` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT de la tabla `tipos_elemento`
--
ALTER TABLE `tipos_elemento`
  MODIFY `id_tipo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `tipos_tesis`
--
ALTER TABLE `tipos_tesis`
  MODIFY `id_tipo_tesis` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `tipo_documento`
--
ALTER TABLE `tipo_documento`
  MODIFY `id_tipo` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT de la tabla `usuario_roles`
--
ALTER TABLE `usuario_roles`
  MODIFY `id_usuario_rol` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `accesos`
--
ALTER TABLE `accesos`
  ADD CONSTRAINT `fk_accesos_objeto` FOREIGN KEY (`fk_id_objeto`) REFERENCES `objetos` (`id_objeto`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_accesos_rol` FOREIGN KEY (`fk_id_rol`) REFERENCES `roles` (`id_rol`) ON DELETE CASCADE;

--
-- Filtros para la tabla `acuses`
--
ALTER TABLE `acuses`
  ADD CONSTRAINT `acuses_ibfk_1` FOREIGN KEY (`fk_id_usuario_remitente`) REFERENCES `usuario` (`id_usuario`),
  ADD CONSTRAINT `acuses_ibfk_2` FOREIGN KEY (`fk_id_usuario_destinatario`) REFERENCES `usuario` (`id_usuario`),
  ADD CONSTRAINT `acuses_ibfk_3` FOREIGN KEY (`fk_id_acuse_original`) REFERENCES `acuses` (`id_acuse`);

--
-- Filtros para la tabla `acuses_adjuntos`
--
ALTER TABLE `acuses_adjuntos`
  ADD CONSTRAINT `acuses_adjuntos_ibfk_1` FOREIGN KEY (`fk_id_acuse`) REFERENCES `acuses` (`id_acuse`);

--
-- Filtros para la tabla `acuses_transferencias`
--
ALTER TABLE `acuses_transferencias`
  ADD CONSTRAINT `acuses_transferencias_ibfk_1` FOREIGN KEY (`fk_id_acuse`) REFERENCES `acuses` (`id_acuse`),
  ADD CONSTRAINT `acuses_transferencias_ibfk_2` FOREIGN KEY (`fk_id_usuario_origen`) REFERENCES `usuario` (`id_usuario`),
  ADD CONSTRAINT `acuses_transferencias_ibfk_3` FOREIGN KEY (`fk_id_usuario_destino`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `auditoria`
--
ALTER TABLE `auditoria`
  ADD CONSTRAINT `fk_auditoria_usuario` FOREIGN KEY (`fk_id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `documentos`
--
ALTER TABLE `documentos`
  ADD CONSTRAINT `documentos_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE;

--
-- Filtros para la tabla `documentos_terna`
--
ALTER TABLE `documentos_terna`
  ADD CONSTRAINT `documentos_terna_ibfk_1` FOREIGN KEY (`pago_terna_id`) REFERENCES `pagos_terna` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `documento_administrativo`
--
ALTER TABLE `documento_administrativo`
  ADD CONSTRAINT `documento_administrativo_fk_id_tipo_foreign` FOREIGN KEY (`fk_id_tipo`) REFERENCES `tipo_documento` (`id_tipo`),
  ADD CONSTRAINT `fk_documento_usuario` FOREIGN KEY (`fk_id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `documento_envios`
--
ALTER TABLE `documento_envios`
  ADD CONSTRAINT `documento_envios_documento_id_foreign` FOREIGN KEY (`documento_id`) REFERENCES `documentos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `documento_envios_enviado_por_foreign` FOREIGN KEY (`enviado_por`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE,
  ADD CONSTRAINT `documento_envios_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE;

--
-- Filtros para la tabla `elementos`
--
ALTER TABLE `elementos`
  ADD CONSTRAINT `elementos_ibfk_1` FOREIGN KEY (`fk_id_tipo`) REFERENCES `tipos_elemento` (`id_tipo`),
  ADD CONSTRAINT `elementos_ibfk_2` FOREIGN KEY (`fk_id_acuse`) REFERENCES `acuses` (`id_acuse`);

--
-- Filtros para la tabla `expediente_docente`
--
ALTER TABLE `expediente_docente`
  ADD CONSTRAINT `fk_expediente_docente_persona` FOREIGN KEY (`fk_id_persona`) REFERENCES `personas` (`id_persona`);

--
-- Filtros para la tabla `expediente_estudiantil`
--
ALTER TABLE `expediente_estudiantil`
  ADD CONSTRAINT `fk_expediente_estudiantil_persona` FOREIGN KEY (`fk_id_persona`) REFERENCES `personas` (`id_persona`);

--
-- Filtros para la tabla `log_login`
--
ALTER TABLE `log_login`
  ADD CONSTRAINT `fk_login_usuario` FOREIGN KEY (`fk_id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD CONSTRAINT `notificaciones_ibfk_1` FOREIGN KEY (`fk_id_usuario_destinatario`) REFERENCES `usuario` (`id_usuario`),
  ADD CONSTRAINT `notificaciones_ibfk_2` FOREIGN KEY (`fk_id_acuse`) REFERENCES `acuses` (`id_acuse`);

--
-- Filtros para la tabla `pagos_terna`
--
ALTER TABLE `pagos_terna`
  ADD CONSTRAINT `pagos_terna_ibfk_1` FOREIGN KEY (`id_administrador`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE,
  ADD CONSTRAINT `pagos_terna_ibfk_2` FOREIGN KEY (`id_asistente`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE;

--
-- Filtros para la tabla `tareas`
--
ALTER TABLE `tareas`
  ADD CONSTRAINT `fk_tarea_usuario_asignado` FOREIGN KEY (`fk_id_usuario_asignado`) REFERENCES `usuario` (`id_usuario`),
  ADD CONSTRAINT `fk_tarea_usuario_creador` FOREIGN KEY (`fk_id_usuario_creador`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `tarea_documento`
--
ALTER TABLE `tarea_documento`
  ADD CONSTRAINT `fk_tarea_documento_documento` FOREIGN KEY (`fk_id_documento`) REFERENCES `documento_administrativo` (`id_documento`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tarea_documento_tarea` FOREIGN KEY (`fk_id_tarea`) REFERENCES `tareas` (`id_tarea`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tarea_documento_tesis` FOREIGN KEY (`fk_id_tesis`) REFERENCES `tesis` (`id_tesis`) ON DELETE SET NULL;

--
-- Filtros para la tabla `tesis`
--
ALTER TABLE `tesis`
  ADD CONSTRAINT `fk_tesis_region` FOREIGN KEY (`fk_id_region`) REFERENCES `regiones` (`id_region`),
  ADD CONSTRAINT `fk_tesis_tipo` FOREIGN KEY (`fk_id_tipo_tesis`) REFERENCES `tipos_tesis` (`id_tipo_tesis`),
  ADD CONSTRAINT `fk_tesis_usuario` FOREIGN KEY (`fk_id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `fk_usuario_add` FOREIGN KEY (`usr_add`) REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL;

--
-- Filtros para la tabla `usuario_roles`
--
ALTER TABLE `usuario_roles`
  ADD CONSTRAINT `fk_usuario_rol_rol` FOREIGN KEY (`fk_id_rol`) REFERENCES `roles` (`id_rol`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_usuario_rol_usuario` FOREIGN KEY (`fk_id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
