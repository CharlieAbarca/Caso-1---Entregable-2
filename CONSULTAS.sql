-- CARLOS ABARCA MORA 2024138701

-- SCRIPT PARA CONSULTAS

-- =========================================RESPUESTA 4.1 (CONSULTA)=========================================
SELECT
    CONCAT(u.name, ' ', u.last_name) AS full_name, -- JUNTAR NOMBRES
    u.email,
    c.name AS country,
    IFNULL(SUM(p.price), 0) AS total_paid_in_colones
FROM
    pay_user u
JOIN
    pay_country c ON u.user_id = c.country_id  -- PAÍS SE RELACIONA CON EL USUARIO
LEFT JOIN
    payments p ON u.user_id = p.user_id 
    AND p.date BETWEEN '2024-01-01' AND CURDATE()  -- FILTRO DE PAGOS DESDE 2024 HASTA HOY
WHERE
    u.active = b'1'  -- ACTIVOS
GROUP BY
    u.user_id, u.name, u.last_name, u.email, c.name
HAVING
    total_paid_in_colones > 0  
ORDER BY
    total_paid_in_colones DESC;
    
-- =========================================RESPUESTA 4.2 (CONSULTA)=========================================
SELECT
    CONCAT(u.name, ' ', u.last_name) AS full_name,
    u.email,
    DATEDIFF(sd.NextExecute, CURDATE()) AS days_remaining,  -- Días faltantes
    sd.NextExecute AS next_renewal_date  -- Fecha de renovación
FROM
    pay_user u
JOIN
    plan_per_user ppu ON u.user_id = ppu.user_id
JOIN
    schedule_details sd ON ppu.planuser_id = sd.planuser_id
WHERE
    DATEDIFF(sd.NextExecute, CURDATE()) BETWEEN 0 AND 15  -- Filtro de 0 a 15 días
    AND u.active = b'1'
ORDER BY
    sd.NextExecute;
    
-- =========================================RESPUESTA 4.3 (CONSULTA)=========================================
-- MÁS USO
SELECT 
    'Top 15 - Más uso' AS ranking_type, -- PARA UBICARME PORQUE ME PIERDO
    full_name,
    email,
    total_sessions,
    total_duration_minutes
FROM (
    SELECT 
        CONCAT(u.name, ' ', u.last_name) AS full_name,
        u.email,
        COUNT(DISTINCT avs.session_id) AS total_sessions,
        ROUND(SUM(TIMESTAMPDIFF(MINUTE, avs.start_time, avs.end_time)), 2) AS total_duration_minutes
    FROM 
        pay_user u
    LEFT JOIN 
        ai_voice_session avs ON u.user_id = avs.user_id
    GROUP BY 
        u.user_id
    ORDER BY 
        total_sessions DESC, total_duration_minutes DESC
    LIMIT 15
) AS top_users

UNION ALL

-- MENOS USO
SELECT 
    'Top 15 - Menos uso' AS ranking_type,
    full_name,
    email,
    total_sessions,
    total_duration_minutes
FROM (
    SELECT 
        CONCAT(u.name, ' ', u.last_name) AS full_name,
        u.email,
        COUNT(DISTINCT avs.session_id) AS total_sessions,
        ROUND(SUM(TIMESTAMPDIFF(MINUTE, avs.start_time, avs.end_time)), 2) AS total_duration_minutes
    FROM 
        pay_user u
    LEFT JOIN 
        ai_voice_session avs ON u.user_id = avs.user_id
    GROUP BY 
        u.user_id
    ORDER BY 
        total_sessions ASC, total_duration_minutes ASC
    LIMIT 15
) AS bottom_users;

-- =========================================RESPUESTA 4.4 (CONSULTA)=========================================
SELECT 
    error_category AS `Tipo de Error`,
    description AS `Descripción Común`,
    COUNT(*) AS `Ocurrencias`,
    GROUP_CONCAT(DISTINCT session_id) AS `Sesiones Afectadas`
FROM (
    SELECT 
        CASE 
            WHEN pet.event_type = 'USER_CORRECTION' THEN 'Corrección del Usuario'
            WHEN pet.event_type = 'SYSTEM_ERROR' THEN 'Error del Sistema'
            WHEN pet.event_type = 'HALLUCINATION' THEN 'Alucinación de la IA'
            ELSE 'Otros'
        END AS error_category,
        ail.description,
        ail.session_id,
        JSON_UNQUOTE(JSON_EXTRACT(ail.additional_info_json, '$.error_type')) AS error_details,
        avs.create_at
    FROM 
        ai_interaction_logs ail
    JOIN 
        pay_event_type pet ON ail.eventtype_id = pet.eventtype_id
    JOIN 
        ai_voice_session avs ON ail.session_id = avs.session_id
    WHERE 
        pet.event_type IN ('USER_CORRECTION', 'SYSTEM_ERROR', 'HALLUCINATION')
        AND avs.create_at BETWEEN '2024-01-01' AND CURDATE()  -- Rango de fechas
) AS error_data
GROUP BY 
    error_category, description
ORDER BY 
    `Ocurrencias` DESC
LIMIT 0, 1000;  -- Asegurar 30+ registros
