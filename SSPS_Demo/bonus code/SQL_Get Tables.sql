-- ==============================================================================================
-- ==============================================================================================
-- Project: 20221017 Rshiny SSPS
-- Date: 01/31/2022
-- Notes: Issue with how we build data.  We are creating water source types to sites that are not relfected in the SiteVariableAmounts_fact.

-- get site Info (pull from SiteVariableAmounts_fact for only usable records)
-- There will be duplicates A.SiteUUID due to D.VariableSpecificCV
SELECT DISTINCT
B.SiteUUID,
B.SiteName,
B.SiteNativeID,
BB.WaDEName as WaDENameS,
B.Longitude,
B.Latitude,
B.PODorPOUSite,
D.VariableCV,
DD.WaDEName as WaDENameV,
D.AggregationIntervalUnitCV as TimeStep,
EE.WadeName as WaDENameBU,
CC.WaDEName as WaDENameWS,
D.VariableSpecificCV
FROM Core.SiteVariableAmounts_fact A
---- SiteVariableAmounts_fact -to- Sites_dim with CV table
LEFT JOIN Core.Sites_dim B ON B.SiteID = A.SiteID
LEFT JOIN CVs.SiteType BB ON BB.Name = B.SiteTypeCV
---- SiteVariableAmounts_fact -to- WaterSource with CV table
LEFT JOIN Core.WaterSources_dim C on C.WaterSourceID = A.WaterSourceID
LEFT JOIN CVs.WaterSourceType CC ON CC.Name = C.WaterSourceTypeCV
----SiteVariableAmounts-to-Variables with CV Table
LEFT JOIN Core.Variables_dim D ON D.VariableSpecificID = A.VariableSpecificID
LEFT JOIN CVs.Variable DD on DD.Name = D.VariableCV
---- Benefical Use CVs Tables
Left Join Core.SitesBridge_BeneficialUses_fact E on E.SiteVariableAmountID = A.SiteVariableAmountID
Left Join CVs.BeneficialUses EE on EE.Name = E.BeneficialUseCV
WHERE B.SiteUUID LIKE '%ssps_S%'
ORDER BY D.VariableSpecificCV, B.SiteUUID;


-- Get geometry
SELECT DISTINCT
A.SiteUUID,
A.PODorPOUSite,
A.Geometry.STAsText() as geometry
FROM CORE.Sites_dim A
WHERE A.SiteUUID LIKE '%ssps_S%'


-- get timeframe for timeframe slider
SELECT DISTINCT
B.SiteUUID,
min(E.Date ) as minTimeFrameStart,
max(F.Date) as maxTimeFrameEnd
FROM Core.SiteVariableAmounts_fact A
---- SiteVariableAmounts-to-Date_dim
LEFT JOIN Core.Date_dim E ON E.DateID = A.TimeframeStartID
LEFT JOIN Core.Date_dim F ON F.DateID = A.TimeframeEndID
---- SiteVariableAmounts-to-Site_dim
LEFT JOIN Core.Sites_dim B ON B.SiteID = A.SiteID
WHERE B.SiteUUID LIKE '%ssps_S%'
GROUP BY B.SiteUUID


-- get PopulationServed for population slider
SELECT DISTINCT
B.SiteUUID,
min(A.PopulationServed ) as minPopulationServed,
max(A.PopulationServed) as maxPopulationServed
FROM Core.SiteVariableAmounts_fact A
---- SiteVariableAmounts-to-Site_dim
LEFT JOIN Core.Sites_dim B ON B.SiteID = A.SiteID
WHERE B.SiteUUID LIKE '%ssps_S%'
GROUP BY B.SiteUUID


-- get links
-- POUstart_PODend_Sites
SELECT DISTINCT
B.SiteUUID as startSiteUUID,
B.PODorPOUSite as startPODorPOUSite,
B.SiteName as startSiteName,
B.Latitude as startLat,
B.Longitude as startLong,
C.SiteUUID as endSiteUUID,
C.PODorPOUSite as endPODorPOUSite, 
C.SiteName as endSiteName,
C.Latitude as endLat,
C.Longitude as endLong
FROM CORE.PODSite_POUSite_fact A
LEFT JOIN Core.Sites_dim B ON A.POUSiteID = B.SiteID
LEFT JOIN Core.Sites_dim C ON A.PODSiteID = C.SiteID
WHERE B.SiteUUID LIKE '%ssps_S%'
ORDER BY B.SiteUUID;

-- PODstart_POUend_Sites
SELECT DISTINCT
B.SiteUUID as startSiteUUID,
B.PODorPOUSite as startPODorPOUSite,
B.SiteName as startSiteName,
B.Latitude as startLat,
B.Longitude as startLong,
C.SiteUUID as endSiteUUID,
C.PODorPOUSite as endPODorPOUSite, 
C.SiteName as endSiteName,
C.Latitude as endLat,
C.Longitude as endLong
FROM CORE.PODSite_POUSite_fact A
LEFT JOIN Core.Sites_dim B ON A.PODSiteID = B.SiteID
LEFT JOIN Core.Sites_dim C ON A.POUSiteID = C.SiteID
WHERE B.SiteUUID LIKE '%ssps_S%'
ORDER BY B.SiteUUID;



---- old way of doing it
---- ssps site data only
---- There will be duplicates A.SiteUUID due to D.VariableSpecificCV
--SELECT DISTINCT
--A.SiteUUID,
--A.SiteName,
--A.SiteNativeID,
--AA.WaDEName as WaDENameS,
--A.Longitude,
--A.Latitude,
--A.PODorPOUSite,
--BBB.WaDEName as WaDENameWS,
--D.AggregationIntervalUnitCV as TimeStep,
--D.VariableCV,
--DD.WaDEName as WaDENameV,
--D.VariableSpecificCV,
--CCC.WadeName as WaDENameBU,
--CASE WHEN C.SiteVariableAmountID IS NOT NULL THEN 'Yes' ELSE 'No' END as HasRecords
--FROM CORE.Sites_dim A
------ Site_dim -to- Bridge -to- WaterSource
--LEFT JOIN Core.WaterSourceBridge_Sites_fact B on A.SiteID = B.SiteID
--LEFT JOIN Core.WaterSources_dim BB on B.WaterSourceID = BB.WaterSourceID
------ Site_dim -to- SiteVariableAmounts_fact
--LEFT JOIN Core.SiteVariableAmounts_fact C ON A.SiteID = C.SiteID
------SiteVariableAmounts-to-Variables
--LEFT JOIN Core.Variables_dim D ON C.VariableSpecificID = D.VariableSpecificID
------ CVs Tables
--LEFT JOIN CVs.SiteType AA ON A.SiteTypeCV = AA.Name
--LEFT JOIN CVs.WaterSourceType BBB ON BB.WaterSourceTypeCV = BBB.Name
--Left Join Core.SitesBridge_BeneficialUses_fact CC on CC.SiteVariableAmountID = C.SiteVariableAmountID
--Left Join CVs.BeneficialUses CCC on CCC.Name = CC.BeneficialUseCV
--LEFT JOIN CVs.Variable DD on DD.Name = D.VariableCV
--WHERE A.SiteUUID LIKE '%ssps_S%'
--ORDER BY HasRecords desc, D.VariableSpecificCV, A.SiteUUID;