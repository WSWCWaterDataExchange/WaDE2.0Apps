-- ==============================================================================================
-- ==============================================================================================
-- Project: Rshiny RE Demo
-- Date: 05/17/2023
-- Notes: asdf

-- get combined reportingunit and regulatoryoverlay info
SELECT DISTINCT
A.StateCV,
A.ReportingUnitUUID,
A.ReportingUnitName,
A.ReportingUnitNativeID,
A.ReportingUnitTypeCV,
C.RegulatoryName,
C.RegulatoryDescription,
C.RegulatoryStatusCV,
C.OversightAgency,
C.RegulatoryStatuteLink,
C.StatutoryEffectiveDate,
C.RegulatoryOverlayTypeCV,
AA.WaDEName as WaDENameRU,
CC1.WaDEName as WaDENameRO,
CC2.WaDEName as WaDENameWS
FROM CORE.ReportingUnits_dim A
---- ReportingUnits_dim -to- RegulatoryReportingUnits_fact -to- RegulatoryOverlay_dim
LEFT JOIN Core.RegulatoryReportingUnits_fact B ON B.ReportingUnitID = A.ReportingUnitID
LEFT JOIN Core.RegulatoryOverlay_dim C on C.RegulatoryOverlayID = B.RegulatoryOverlayID
---- CVs Tables
LEFT JOIN CVs.ReportingUnitType AA ON AA.Name = A.ReportingUnitTypeCV
LEFT JOIN CVs.RegulatoryOverlayType CC1 ON CC1.Name = C.RegulatoryOverlayTypeCV
LEFT JOIN CVs.WaterSourceType CC2 ON CC2.Name = C.WaterSourceTypeCV
WHERE A.ReportingUnitUUID LIKE '%re_RU%'
ORDER BY A.ReportingUnitUUID;


-- Get geometry of reportingunit
-- works better to get separate and join after
SELECT DISTINCT
A.ReportingUnitUUID,
A.Geometry.STAsText() as geometry
FROM CORE.ReportingUnits_dim A
WHERE A.ReportingUnitUUID LIKE '%re_RU%'
ORDER BY A.ReportingUnitUUID;


SELECT DISTINCT
A.ReportingUnitUUID,
A.Geometry.STAsText() as geometry
FROM CORE.ReportingUnits_dim A
WHERE A.ReportingUnitUUID LIKE 'NMre_RU%'
ORDER BY A.ReportingUnitUUID;


-- wr sites are too hard to work with leaflet and a regulatory overlay, ignore for now
---- get wr sites affected by regulatory overlay areas
---- this will return a random set each time
--SELECT DISTINCT
--B.SiteUUID,
--B.SiteName,
--B.SiteNativeID,
--BB.WaDEName as WaDENameS,
--B.Longitude,
--B.Latitude,
--B.PODorPOUSite,
--CCC.WaDEName as WaDENameWS,
--DD.AllocationUUID,
--EEE.ReportingUnitUUID
--FROM Core.RegulatoryOverlayBridge_Sites_fact A TABLESAMPLE (0.2 PERCENT)
---- sites info
--LEFT JOIN Core.Sites_dim B on B.SiteID = A.SiteID
--LEFT JOIN CVs.SiteType BB ON BB.Name = B.SiteTypeCV
---- watersource info
--LEFT JOIN Core.WaterSourceBridge_Sites_fact C on C.SiteID = B.SiteID
--LEFT JOIN Core.WaterSources_dim CC on CC.WaterSourceID = C.WaterSourceID
--LEFT JOIN CVs.WaterSourceType CCC ON CCC.Name = CC.WaterSourceTypeCV
---- allocationamounts info
--LEFT JOIN Core.AllocationBridge_Sites_fact D on D.SiteID = B.SiteID
--LEFT JOIN Core.AllocationAmounts_fact DD on DD.AllocationAmountID = D.AllocationAmountID
---- reportingunit info
--LEFT JOIN Core.RegulatoryOverlay_dim E on E.RegulatoryOVerlayID = A.RegulatoryOVerlayID
--LEFT JOIN Core.RegulatoryReportingUnits_fact EE on EE.RegulatoryOVerlayID = E.RegulatoryOVerlayID
--LEFT JOIN Core.ReportingUnits_dim EEE on EEE.ReportingUnitID = EE.ReportingUnitID
--WHERE B.PODorPOUSite = 'POD' and B.SiteUUID LIKE 'NMwr_S%'
--ORDER BY B.SiteUUID;