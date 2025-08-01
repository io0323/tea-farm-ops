-- フィールドの初期データ
INSERT INTO fields (name, location, area_size, soil_type, notes) VALUES
('北茶園A', '静岡県静岡市葵区', 2.5, '火山灰土', '標高300m、南向き斜面'),
('南茶園B', '静岡県静岡市葵区', 1.8, 'ローム質土', '標高250m、日当たり良好'),
('東茶園C', '静岡県静岡市葵区', 3.2, '粘土質土', '標高400m、霧が発生しやすい'),
('西茶園D', '静岡県静岡市葵区', 1.5, '砂質土', '標高200m、排水良好');

-- タスクの初期データ
INSERT INTO tasks (task_type, field_id, assigned_worker, start_date, end_date, status, notes) VALUES
('PRUNING', 1, '田中太郎', '2024-01-15', '2024-01-20', 'COMPLETED', '春の剪定作業完了'),
('FERTILIZING', 2, '佐藤花子', '2024-01-25', '2024-01-26', 'COMPLETED', '有機肥料を施用'),
('HARVESTING', 1, '田中太郎', '2024-02-01', '2024-02-05', 'IN_PROGRESS', '新茶の収穫中'),
('OTHER', 3, '山田次郎', '2024-02-10', '2024-02-12', 'PENDING', '機械除草を予定'),
('PEST_CONTROL', 4, '佐藤花子', '2024-02-15', '2024-02-16', 'PENDING', '病害虫防除');

-- 収穫記録の初期データ
INSERT INTO harvest_records (field_id, harvest_date, quantity_kg, tea_grade, notes) VALUES
(1, '2024-01-20', 45.5, 'PREMIUM', '新茶の初摘み、品質良好'),
(2, '2024-01-25', 38.2, 'HIGH', '二番茶、香り豊か'),
(3, '2024-02-01', 52.1, 'PREMIUM', '新茶、甘みが強い'),
(1, '2024-02-05', 41.8, 'HIGH', '二番茶、渋み適度'),
(4, '2024-02-10', 35.6, 'MEDIUM', '三番茶、香り控えめ');

-- 天候観測の初期データ
INSERT INTO weather_observations (date, field_id, temperature, rainfall, humidity, pests_seen, notes) VALUES
('2024-01-15', 1, 15.5, 0.0, 65.0, NULL, '晴天、作業に適した天候'),
('2024-01-20', 2, 18.2, 5.5, 78.0, 'アブラムシ', '小雨、害虫確認'),
('2024-01-25', 3, 12.8, 0.0, 45.0, NULL, '晴天、乾燥注意'),
('2024-02-01', 4, 20.1, 2.0, 70.0, 'カメムシ', '曇り、害虫発生'),
('2024-02-05', 1, 16.5, 8.0, 85.0, NULL, '雨、湿度高し'),
('2024-02-10', 2, 14.2, 0.0, 60.0, NULL, '晴天、作業好適'); 