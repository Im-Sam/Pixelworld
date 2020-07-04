--[[
    CURRENT PROGRESS
    Up to Arms on Clothing
]]
local isHandsUp = false
local cameraFunc1
local cameras
local inShop = false
revertSettings = nil

local currentSetting = {
    ['playerModel']         = "",
    ['skin'] = {
        ['mom']             = 0,
        ['dad']             = 0,
        ['age']             = { ['style'] = 0, ['opacity'] = 0.0},
        ['eye']             = -1,
        ['nose']            = { ['width'] = 0.0, ['peak_height'] = 0.0, ['length'] = 0.0, ['peak_lowering'] = 0.0, ['bone_twist'] = 0.0 },
        ['lips']            = { },
        ['cheek']           = { ['bonewidth'] = 0.0, ['high'] = 0.0, ['width'] = 0.0 },
        ['jaw']             = { ['width'] = 0.0, ['length'] = 0.0 },
        ['chin']            = { ['lowering'] = 0.0, ['length'] = 0.0, ['width'] = 0.0, ['hole'] = 0.0},
        ['neck']            = 0.0,
        ['eyebrow']         = { ['high'] = 0.0, ['forward'] = 0 },
        ['blemishes']       = { ['style'] = 0, ['opacity'] = 0 },
        ['complexion']      = { ['style'] = 0, ['opacity'] = 0 },
        ['resemblance']     = 0,
        ['skinmix']         = 0,
    },
    ['clothing'] = {
        ['tshirt']          = { ['one'] = -1, ['two'] = -1},
        ['torso']           = { ['one'] = -1, ['two'] = -1},
        ['arms']            = { ['one'] = -1, ['two'] = -1},
        ['pants']           = { ['one'] = 4, ['two'] = 1},
        ['shoes']           = { ['one'] = -1, ['two'] = -1},
    },
    ['facial'] = {
        ['hair']            = { ['style'] = 0, ['color1'] = 0,  ['color2'] = 0 },
        ['beard']           = { ['style'] = 0, ['opacity'] = 0.0, ['color1'] = 1, ['color2'] = 1},
        ['eyebrow']         = { ['style'] = 1, ['opacity'] = 0.5, ['color1'] = 1, ['color2'] = 1},
        ['lipstick']        = { ['style'] = 1, ['opacity'] = 0.0, ['color1'] = 1, ['color2'] = 1},
        ['makeup']          = { ['style'] = 1, ['opacity'] = 0.0, ['color1'] = 1, ['color2'] = 1}
    },
    ['accessories'] = {
        ['chain']           = { ['one'] = -1, ['two'] = -1},
        ['decals']          = { ['one'] = -1, ['two'] = -1},
        ['mask']            = { ['one'] = -1, ['two'] = -1},
        ['bproof']          = { ['one'] = -1, ['two'] = -1},
        ['bags']            = { ['one'] = -1, ['two'] = -1},
        ['ears']            = { ['one'] = -1, ['two'] = -1},
        ['helmet']          = { ['one'] = -1, ['two'] = -1},
        ['glasses']         = { ['one'] = -1, ['two'] = -1},
        ['watches']         = { ['one'] = -1, ['two'] = -1},
        ['bracelets']       = { ['one'] = -1, ['two'] = -1},
    },
}

local playerSex = nil

-- Option Generation
local skinOptions = {
    ['models']              = { ['female'] = {'a_f_m_beach_01','a_f_m_bevhills_01','a_f_m_bevhills_02','a_f_m_bodybuild_01','a_f_m_business_02','a_f_m_downtown_01','a_f_m_eastsa_01','a_f_m_eastsa_02','a_f_m_fatbla_01','a_f_m_fatcult_01','a_f_m_fatwhite_01','a_f_m_ktown_01','a_f_m_ktown_02','a_f_m_prolhost_01','a_f_m_salton_01','a_f_m_skidrow_01','a_f_m_soucentmc_01','a_f_m_soucent_01','a_f_m_soucent_02','a_f_m_tourist_01','a_f_m_trampbeac_01','a_f_m_tramp_01','a_f_o_genstreet_01','a_f_o_indian_01','a_f_o_ktown_01','a_f_o_salton_01','a_f_o_soucent_01','a_f_o_soucent_02','a_f_y_beach_01','a_f_y_bevhills_01','a_f_y_bevhills_02','a_f_y_bevhills_03','a_f_y_bevhills_04','a_f_y_business_01','a_f_y_business_02','a_f_y_business_03','a_f_y_business_04','a_f_y_eastsa_01','a_f_y_eastsa_02','a_f_y_eastsa_03','a_f_y_epsilon_01','a_f_y_fitness_01','a_f_y_fitness_02','a_f_y_genhot_01','a_f_y_golfer_01','a_f_y_hiker_01','a_f_y_hippie_01','a_f_y_hipster_01','a_f_y_hipster_02','a_f_y_hipster_03','a_f_y_hipster_04','a_f_y_indian_01','a_f_y_juggalo_01','a_f_y_runner_01','a_f_y_rurmeth_01','a_f_y_scdressy_01','a_f_y_skater_01','a_f_y_soucent_01','a_f_y_soucent_02','a_f_y_soucent_03','a_f_y_tennis_01','a_f_y_topless_01','a_f_y_tourist_01','a_f_y_tourist_02','a_f_y_vinewood_01','a_f_y_vinewood_02','a_f_y_vinewood_03','a_f_y_vinewood_04','a_f_y_yoga_01','cs_tracydisanto','cs_tanisha', 'cs_patricia', 'cs_mrsphillips', 'cs_mrs_thornhill', 'cs_natalia', 'cs_molly', 'cs_movpremf_01', 'cs_maryann', 'cs_michelle', 'cs_marnie', 'cs_magenta', 'cs_janet', 'cs_jewelass', 'cs_guadalope', 'cs_gurk',  'cs_debra', 'cs_denise', 'cs_amandatownley',  'cs_ashley', 'csb_screen_writer', 'csb_stripper_01', 'csb_stripper_02', 'csb_tonya', 'csb_maude', 'csb_denise_friend', 'csb_abigail', 'csb_anita', 'g_f_y_ballas_01','g_f_y_families_01','g_f_y_lost_01','g_f_y_vagos_01','s_f_m_fembarber','s_f_m_maid_01','s_f_m_shop_high','s_f_m_sweatshop_01','s_f_y_airhostess_01','s_f_y_bartender_01','s_f_y_baywatch_01','s_f_y_factory_01','s_f_y_hooker_01','s_f_y_hooker_02','s_f_y_hooker_03','s_f_y_migrant_01','s_f_y_movprem_01','s_f_y_shop_low','s_f_y_shop_mid','s_f_y_stripperlite','s_f_y_stripper_01','s_f_y_stripper_02','s_f_y_sweatshop_01','u_f_m_corpse_01','u_f_m_miranda','u_f_m_promourn_01','u_f_o_moviestar','u_f_o_prolhost_01','u_f_y_bikerchic','u_f_y_comjane','u_f_y_hotposh_01','u_f_y_jewelass_01','u_f_y_mistress','u_f_y_poppymich','u_f_y_princess','u_f_y_spyactress'},
                                ['male'] = {'a_m_m_afriamer_01','a_m_m_beach_01','a_m_m_beach_02','a_m_m_bevhills_01','a_m_m_bevhills_02','a_m_m_business_01','a_m_m_eastsa_01','a_m_m_eastsa_02','a_m_m_farmer_01','a_m_m_fatlatin_01','a_m_m_genfat_01','a_m_m_genfat_02','a_m_m_golfer_01','a_m_m_hasjew_01','a_m_m_hillbilly_01','a_m_m_hillbilly_02','a_m_m_indian_01','a_m_m_ktown_01','a_m_m_malibu_01','a_m_m_mexcntry_01','a_m_m_mexlabor_01','a_m_m_og_boss_01','a_m_m_paparazzi_01','a_m_m_polynesian_01','a_m_m_prolhost_01','a_m_m_rurmeth_01','a_m_m_salton_01','a_m_m_salton_02','a_m_m_salton_03','a_m_m_salton_04','a_m_m_skater_01','a_m_m_skidrow_01','a_m_m_socenlat_01','a_m_m_soucent_01','a_m_m_soucent_02','a_m_m_soucent_03','a_m_m_soucent_04','a_m_m_stlat_02','a_m_m_tennis_01','a_m_m_tourist_01','a_m_m_trampbeac_01','a_m_m_tramp_01','a_m_m_tranvest_01','a_m_m_tranvest_02','a_m_o_acult_01','a_m_o_acult_02','a_m_o_beach_01','a_m_o_genstreet_01','a_m_o_ktown_01','a_m_o_salton_01','a_m_o_soucent_01','a_m_o_soucent_02','a_m_o_soucent_03','a_m_o_tramp_01','a_m_y_acult_01','a_m_y_acult_02','a_m_y_beachvesp_01','a_m_y_beachvesp_02','a_m_y_beach_01','a_m_y_beach_02','a_m_y_beach_03','a_m_y_bevhills_01','a_m_y_bevhills_02','a_m_y_breakdance_01','a_m_y_busicas_01','a_m_y_business_01','a_m_y_business_02','a_m_y_business_03','a_m_y_cyclist_01','a_m_y_dhill_01','a_m_y_downtown_01','a_m_y_eastsa_01','a_m_y_eastsa_02','a_m_y_epsilon_01','a_m_y_epsilon_02','a_m_y_gay_01','a_m_y_gay_02','a_m_y_genstreet_01','a_m_y_genstreet_02','a_m_y_golfer_01','a_m_y_hasjew_01','a_m_y_hiker_01','a_m_y_hippy_01','a_m_y_hipster_01','a_m_y_hipster_02','a_m_y_hipster_03','a_m_y_indian_01','a_m_y_jetski_01','a_m_y_juggalo_01','a_m_y_ktown_01','a_m_y_ktown_02','a_m_y_latino_01','a_m_y_methhead_01','a_m_y_mexthug_01','a_m_y_motox_01','a_m_y_motox_02','a_m_y_musclbeac_01','a_m_y_musclbeac_02','a_m_y_polynesian_01','a_m_y_roadcyc_01','a_m_y_runner_01','a_m_y_runner_02','a_m_y_salton_01','a_m_y_skater_01','a_m_y_skater_02','a_m_y_soucent_01','a_m_y_soucent_02','a_m_y_soucent_03','a_m_y_soucent_04','a_m_y_stbla_01','a_m_y_stbla_02','a_m_y_stlat_01','a_m_y_stwhi_01','a_m_y_stwhi_02','a_m_y_sunbathe_01','a_m_y_surfer_01','a_m_y_vindouche_01','a_m_y_vinewood_01','a_m_y_vinewood_02','a_m_y_vinewood_03','a_m_y_vinewood_04','a_m_y_yoga_01','csb_anton','csb_ballasog','csb_burgerdrug','csb_car3guy1','csb_car3guy2','csb_chef','csb_chin_goon','csb_cletus', 'csb_customer', 'csb_fos_rep', 'csb_g', 'csb_groom', 'csb_grove_str_dlr', 'csb_hao', 'csb_hugh', 'csb_imran', 'csb_janitor', 'csb_ortega', 'csb_oscar', 'csb_porndudes', 'csb_prologuedriver', 'csb_ramp_gang',  'csb_ramp_hic', 'csb_ramp_hipster', 'csb_ramp_mex', 'csb_reporter', 'csb_roccopelosi', 'csb_trafficwarden','cs_bankman', 'cs_barry', 'cs_beverly', 'cs_brad', 'cs_carbuyer', 'cs_chengsr', 'cs_chrisformage', 'cs_clay', 'cs_dale', 'cs_davenorton', 'cs_devin', 'cs_dom', 'cs_dreyfuss', 'cs_drfriedlander', 'cs_fabien', 'cs_floyd', 'cs_hunter', 'cs_jimmyboston', 'cs_jimmydisanto', 'cs_joeminuteman', 'cs_johnnyklebitz', 'cs_josef', 'cs_josh', 'cs_lazlow', 'cs_lestercrest', 'cs_lifeinvad_01', 'cs_manuel', 'cs_martinmadrazo', 'cs_milton', 'cs_movpremmale', 'cs_mrk', 'cs_nervousron', 'cs_nigel', 'cs_old_man1a', 'cs_old_man2', 'cs_omega', 'cs_orleans', 'cs_paper', 'cs_priest', 'cs_prolsec_02', 'cs_russiandrunk', 'cs_siemonyetarian', 'cs_solomon', 'cs_stevehains', 'cs_stretch', 'cs_taocheng', 'cs_taostranslator', 'cs_tenniscoach', 'cs_terry', 'cs_tom', 'cs_tomepsilon', 'cs_wade', 'cs_zimbor', 'g_m_m_armboss_01','g_m_m_armgoon_01','g_m_m_armlieut_01','g_m_m_chemwork_01','g_m_m_chiboss_01','g_m_m_chicold_01','g_m_m_chigoon_01','g_m_m_chigoon_02','g_m_m_korboss_01','g_m_m_mexboss_01','g_m_m_mexboss_02','g_m_y_armgoon_02','g_m_y_azteca_01','g_m_y_ballaeast_01','g_m_y_ballaorig_01','g_m_y_ballasout_01','g_m_y_famca_01','g_m_y_famdnf_01','g_m_y_famfor_01','g_m_y_korean_01','g_m_y_korean_02','g_m_y_korlieut_01','g_m_y_lost_01','g_m_y_lost_02','g_m_y_lost_03','g_m_y_mexgang_01','g_m_y_mexgoon_01','g_m_y_mexgoon_02','g_m_y_mexgoon_03','g_m_y_pologoon_01','g_m_y_pologoon_02','g_m_y_salvaboss_01','g_m_y_salvagoon_01','g_m_y_salvagoon_02','g_m_y_salvagoon_03','g_m_y_strpunk_01','g_m_y_strpunk_02','hc_driver', 'hc_gunman', 'hc_hacker', 's_m_m_ammucountry','s_m_m_autoshop_01','s_m_m_autoshop_02','s_m_m_bouncer_01','s_m_m_ciasec_01','s_m_m_cntrybar_01','s_m_m_dockwork_01','s_m_m_doctor_01','s_m_m_fiboffice_02','s_m_m_gaffer_01','s_m_m_gardener_01','s_m_m_gentransport','s_m_m_hairdress_01','s_m_m_highsec_01','s_m_m_highsec_02','s_m_m_janitor','s_m_m_lathandy_01','s_m_m_lifeinvad_01','s_m_m_linecook','s_m_m_lsmetro_01','s_m_m_mariachi_01','s_m_m_migrant_01','s_m_m_movprem_01','s_m_m_movspace_01','s_m_m_pilot_01','s_m_m_pilot_02','s_m_m_postal_01','s_m_m_postal_02','s_m_m_scientist_01','s_m_m_strperf_01','s_m_m_strpreach_01','s_m_m_strvend_01','s_m_m_trucker_01','s_m_m_ups_01','s_m_m_ups_02','s_m_o_busker_01','s_m_y_airworker','s_m_y_ammucity_01','s_m_y_armymech_01','s_m_y_autopsy_01','s_m_y_barman_01','s_m_y_baywatch_01','s_m_y_busboy_01','s_m_y_chef_01','s_m_y_clown_01','s_m_y_construct_01','s_m_y_construct_02','s_m_y_dealer_01','s_m_y_devinsec_01','s_m_y_dockwork_01','s_m_y_dwservice_01','s_m_y_dwservice_02','s_m_y_factory_01','s_m_y_garbage','s_m_y_grip_01','s_m_y_mime','s_m_y_pestcont_01','s_m_y_pilot_01','s_m_y_prismuscl_01','s_m_y_prisoner_01','s_m_y_robber_01','s_m_y_shop_mask','s_m_y_strvend_01','s_m_y_uscg_01','s_m_y_valet_01','s_m_y_waiter_01','s_m_y_winclean_01','s_m_y_xmech_01','s_m_y_xmech_02','u_m_m_aldinapoli','u_m_m_bankman','u_m_m_bikehire_01','u_m_m_fibarchitect','u_m_m_filmdirector','u_m_m_glenstank_01','u_m_m_griff_01','u_m_m_jesus_01','u_m_m_jewelsec_01','u_m_m_jewelthief','u_m_m_markfost','u_m_m_partytarget','u_m_m_promourn_01','u_m_m_rivalpap','u_m_m_spyactor','u_m_m_willyfist','u_m_o_finguru_01','u_m_o_taphillbilly','u_m_o_tramp_01','u_m_y_abner','u_m_y_antonb','u_m_y_babyd','u_m_y_baygor','u_m_y_burgerdrug_01','u_m_y_chip','u_m_y_cyclist_01','u_m_y_fibmugger_01','u_m_y_guido_01','u_m_y_gunvend_01','u_m_y_hippie_01','u_m_y_imporage','u_m_y_justin','u_m_y_mani','u_m_y_militarybum','u_m_y_paparazzi','u_m_y_party_01','u_m_y_pogo_01','u_m_y_prisoner_01','u_m_y_proldriver_01','u_m_y_rsranger_01','u_m_y_sbike','u_m_y_staggrm_01','u_m_y_tattoo_01'}
                            },    
    ['skin'] = {
        ['mom']             = {0,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,45},
        ['dad']             = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,26,27,28,29,30,31,32,33},
        ['age']             = { ['style'] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14}, ['opacity'] = {0,1,2,3,4,5,6,7,8,9,10}},
        ['eye']             = -1,
        ['nose']            = { ['width'] = {"-2.0", "-1.9", "-1.8", "-1.7", "-1.6", "-1.5", "-1.4", "-1.3", "-1.2", "-1.1", "-1.0", "-0.9", "-0.8", "-0.7", "-0.6", "-0.5", "-0.4", "-0.3", "-0.2", "-0.1", "0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0"}, ['peak_height'] = {"-2.0", "-1.9", "-1.8", "-1.7", "-1.6", "-1.5", "-1.4", "-1.3", "-1.2", "-1.1", "-1.0", "-0.9", "-0.8", "-0.7", "-0.6", "-0.5", "-0.4", "-0.3", "-0.2", "-0.1", "0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0"}, ['length'] = {"-2.0", "-1.9", "-1.8", "-1.7", "-1.6", "-1.5", "-1.4", "-1.3", "-1.2", "-1.1", "-1.0", "-0.9", "-0.8", "-0.7", "-0.6", "-0.5", "-0.4", "-0.3", "-0.2", "-0.1", "0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0"}, ['peak_lowering'] = {"-2.0", "-1.9", "-1.8", "-1.7", "-1.6", "-1.5", "-1.4", "-1.3", "-1.2", "-1.1", "-1.0", "-0.9", "-0.8", "-0.7", "-0.6", "-0.5", "-0.4", "-0.3", "-0.2", "-0.1", "0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0"}, ['bone_twist'] = {"-2.0", "-1.9", "-1.8", "-1.7", "-1.6", "-1.5", "-1.4", "-1.3", "-1.2", "-1.1", "-1.0", "-0.9", "-0.8", "-0.7", "-0.6", "-0.5", "-0.4", "-0.3", "-0.2", "-0.1", "0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0"} },
        ['lips']            = { },
        ['cheek']           = { ['bonewidth'] = {"-2.0", "-1.9", "-1.8", "-1.7", "-1.6", "-1.5", "-1.4", "-1.3", "-1.2", "-1.1", "-1.0", "-0.9", "-0.8", "-0.7", "-0.6", "-0.5", "-0.4", "-0.3", "-0.2", "-0.1", "0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0"}, ['high'] = {"-2.0", "-1.9", "-1.8", "-1.7", "-1.6", "-1.5", "-1.4", "-1.3", "-1.2", "-1.1", "-1.0", "-0.9", "-0.8", "-0.7", "-0.6", "-0.5", "-0.4", "-0.3", "-0.2", "-0.1", "0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0"}, ['width'] = {"-2.0", "-1.9", "-1.8", "-1.7", "-1.6", "-1.5", "-1.4", "-1.3", "-1.2", "-1.1", "-1.0", "-0.9", "-0.8", "-0.7", "-0.6", "-0.5", "-0.4", "-0.3", "-0.2", "-0.1", "0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0"} },
        ['jaw']             = { ['width'] = {"-2.0", "-1.9", "-1.8", "-1.7", "-1.6", "-1.5", "-1.4", "-1.3", "-1.2", "-1.1", "-1.0", "-0.9", "-0.8", "-0.7", "-0.6", "-0.5", "-0.4", "-0.3", "-0.2", "-0.1", "0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0"}, ['length'] = {"-2.0", "-1.9", "-1.8", "-1.7", "-1.6", "-1.5", "-1.4", "-1.3", "-1.2", "-1.1", "-1.0", "-0.9", "-0.8", "-0.7", "-0.6", "-0.5", "-0.4", "-0.3", "-0.2", "-0.1", "0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0"} },
        ['chin']            = { ['lowering'] = {"-2.0", "-1.9", "-1.8", "-1.7", "-1.6", "-1.5", "-1.4", "-1.3", "-1.2", "-1.1", "-1.0", "-0.9", "-0.8", "-0.7", "-0.6", "-0.5", "-0.4", "-0.3", "-0.2", "-0.1", "0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0"}, ['length'] = {"-2.0", "-1.9", "-1.8", "-1.7", "-1.6", "-1.5", "-1.4", "-1.3", "-1.2", "-1.1", "-1.0", "-0.9", "-0.8", "-0.7", "-0.6", "-0.5", "-0.4", "-0.3", "-0.2", "-0.1", "0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0"}, ['width'] = {"-2.0", "-1.9", "-1.8", "-1.7", "-1.6", "-1.5", "-1.4", "-1.3", "-1.2", "-1.1", "-1.0", "-0.9", "-0.8", "-0.7", "-0.6", "-0.5", "-0.4", "-0.3", "-0.2", "-0.1", "0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0"}, ['hole'] = {"-2.0", "-1.9", "-1.8", "-1.7", "-1.6", "-1.5", "-1.4", "-1.3", "-1.2", "-1.1", "-1.0", "-0.9", "-0.8", "-0.7", "-0.6", "-0.5", "-0.4", "-0.3", "-0.2", "-0.1", "0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0"}},
        ['neck']            = {"-2.0", "-1.9", "-1.8", "-1.7", "-1.6", "-1.5", "-1.4", "-1.3", "-1.2", "-1.1", "-1.0", "-0.9", "-0.8", "-0.7", "-0.6", "-0.5", "-0.4", "-0.3", "-0.2", "-0.1", "0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0"},
        ['eyebrow']         = { ['high'] = {"-2.0", "-1.9", "-1.8", "-1.7", "-1.6", "-1.5", "-1.4", "-1.3", "-1.2", "-1.1", "-1.0", "-0.9", "-0.8", "-0.7", "-0.6", "-0.5", "-0.4", "-0.3", "-0.2", "-0.1", "0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0"}, ['forward'] = 1 },
        ['blemishes']       = { ['style'] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23}, ['opacity'] = {0,1,2,3,4,5,6,7,8,9,10} },
        ['complexion']      = { ['style'] = {0,1,2,3,4,5,6,7,8,9,10,11}, ['opacity'] = {0,1,2,3,4,5,6,7,8,9,10} },
        ['resemblance']     = { 0,1,2,3,4,5,6,7,8,9 },
        ['skinmix']         = { 0,1,2,3,4,5,6,7,8,9 },
    },
    ['clothing'] = {
        ['tshirt']          = { },
        ['torso']           = { },
        ['arms']            = { },
        ['pants']           = { },
        ['shoes']           = { },
    },
    ['facial'] = {
        ['hair']            = { ['style'] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73} },
        ['beard']           = { ['style'] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23}, ['opacity'] = {0,1,2,3,4,5,6,7,8,9,10}},
        ['custombeards']    = { 1005,1007,1009,1013,1014,1015,1057,1058,1059,1060,1061,1062 },
        ['eyebrow']         = { ['style'] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33}, ['opacity'] = {0,1,2,3,4,5,6,7,8,9,10}},
        ['lipstick']        = { ['style'] = {0,1,2,3,4,5,6,7,8,9}, ['opacity'] = {0,1,2,3,4,5,6,7,8,9,10}},
        ['makeup']          = { ['style'] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72}, ['opacity'] = {0,1,2,3,4,5,6,7,8,9,10}}
    },
    ['accessories'] = {
        ['chain']           = { ['one'] = -1, ['two'] = -1},
        ['decals']          = { ['one'] = -1, ['two'] = -1},
        ['mask']            = { ['one'] = -1, ['two'] = -1},
        ['bproof']          = { ['one'] = -1, ['two'] = -1},
        ['bags']            = { ['one'] = -1, ['two'] = -1},
        ['ears']            = { ['one'] = -1, ['two'] = -1},
        ['helmet']          = { ['one'] = -1, ['two'] = -1},
        ['glasses']         = { ['one'] = -1, ['two'] = -1},
        ['watches']         = { ['one'] = -1, ['two'] = -1},
        ['bracelets']       = { ['one'] = -1, ['two'] = -1},
    },
    ['colors'] = { [0] = "Shark", [1] = "Shark", [2] = "Dune", [3] =  "Treehouse", [4] = "Metallic Bronze", [5] = "Irish Coffee", [6] = "Shingle Fawn", [7] = "Millbrook", [8] = "Tobacco Brown", [9] = "Shadow", [10] = "Leather", [11] = "Sandal", [12] = "Sandal", [13] = "Husk", [14] = "Tumbleweed", [15] = "Brandy", [16] = "Dirt", [17] = "Ironstone", [18] = "Metallic Copper", [19] = "Dark Tan", [20] = "Mahogany", [21] = "Smokey Topaz", [22] = "Cognac", [23] = "Tuscany", [24] = "Paarl", [25] = "Paarl", [26] = "Granite Gray", [27] = "Gray", [28] = "Silver Chalice", [29] = "Silver", [30] = "Mulled Wine", [31] = "Cyber Grape", [32] = "Cosmic", [33] = "Lavender Magenta", [34] = "Frostbite", [35] = "Wewak", [36] = "Niagara", [37] = "Orient", [38] = "Regal Blue", [39] = "Chateau Green", [40] = "Eucalyptus", [41] = "Green Pea", [42] = "Earls Green", [43] = "Christi", [44] = "Slimy Green", [45] = "Equator", [46] = "Corn", [47] = "Tangerine", [48] = "Jaffa", [49] = "Coral", [50] = "Big Foot Feet", [51] = "Jasper", [52] = "Thunderbird", [53] = "Bright Red", [54] = "Red Berry", [55] = "Licorice", [56] = "Zeus", [57] = "Zeus", [58] = "Treehouse", [59] = "Oil", [60] = "Zeus", [61] = "Black", [62] = "Flint", [63] = "Dirt"}
}

function spawnCreator(inst)
    local playerPed = GetPlayerPed(-1)
    if not inShop then
        FreezeEntityPosition(playerPed, true)
        SetEntityCoords(playerPed, tonumber(408.78), tonumber(-998.57), tonumber(-98.99), 0.0, 0.0, 0.0, false)
        SetEntityHeading(playerPed, tonumber(271.38))
    end
end

exports('getCurrentSkin', function()
    return currentSetting
end)

function finishCreator(inst)
    local playerPed = GetPlayerPed(-1)
    DoScreenFadeOut(1500)
    Citizen.Wait(1601)
    SetEntityCoords(playerPed, -1045.02, -2750.25, 21.37, 0.0, 0.0, 0.0, false)
    SetEntityHeading(playerPed, 330.07)
    if not inShop then
        FreezeEntityPosition(playerPed, false)
        RenderScriptCams(false, false, 0, false, false)
        DestroyAllCams(true)
    end
    Citizen.Wait(1500)
    DoScreenFadeIn(1500) 
    TriggerServerEvent('pw:playerSpawned')
    TriggerEvent('pw:playerSpawned')       
end

RegisterNetEvent('pw_instance:onCreate')
AddEventHandler('pw_instance:onCreate', function(instance)
    if instance.type == 'charCreator' then
		TriggerEvent('pw_instance:enter', instance)
	end
end)

AddEventHandler('pw_instance:loaded', function()
    TriggerEvent('pw_instance:registerType', 'charCreator', function(instance)
		spawnCreator(instance.data.owner)
	end, function(instance)
		finishCreator(instance.data.owner)
	end)
end)

RegisterNetEvent('instance:onPlayerLeft')
AddEventHandler('instance:onPlayerLeft', function(instance, player)
	if player == instance.host then
		TriggerEvent('instance:leave')
	end
end)

RegisterNetEvent('pw_base:client:startCreationCharacter')
AddEventHandler('pw_base:client:startCreationCharacter', function(sex)
    local cam1 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 410.3, -998.54, -98.99-0.10, 0.00, 0.00, 0.00, 75.0, false, 2)
    local cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 409.5, -998.54, -98.99+0.70, 0.00, 0.00, 0.00, 75.0, false, 2)
    local cam3 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 409.3, -998.54, -98.99+0.70, 0.00, 0.00, 0.00, 75.0, false, 2)
    local cam4 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 410.3, -998.54, -98.99-0.10, 0.00, 0.00, 0.00, 75.0, false, 2)
    local cam5 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 408.7, -999.00, -98.99+0.70, 0.00, 0.00, 0.00, 75.0, false, 2)
    local cam6 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 408.7, -997.70, -98.99, 0.00, 0.00, 0.00, 75.0, false, 2)
    local cam7 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 408.7, -999.50, -98.99, 0.00, 0.00, 0.00, 75.0, false, 2)
    local cam8 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 409.5, -998.54, -98.99-0.70, 0.00, 0.00, 0.00, 75.0, false, 2)
    local cam9 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 408.9, -999.00, -98.99+0.70, 0.00, 0.00, 0.00, 75.0, false, 2)

    cameras = {
        ['clothing'] = cam1,
        ['facial'] = cam2,
        ['skin'] = cam3,
        ['accessories'] = cam4,
        ['ears'] = cam5,
        ['nose'] = cam9,
        ['arms'] = { ['right'] = cam6, ['left'] = cam7 },
        ['shoes'] = cam8
    }
        PointCamAtCoord(cameras.accessories,  408.78, -998.57, -98.99-0.10)
        PointCamAtCoord(cameras.ears,  408.78, -998.57, -98.99+0.70)
        PointCamAtCoord(cameras.nose,  408.9, -998.57, -98.99+0.70)
        PointCamAtCoord(cameras.arms.right,  408.78, -998.57, -98.99)
        PointCamAtCoord(cameras.arms.left,  408.78, -998.57, -98.99)
        PointCamAtCoord(cameras.clothing,  408.78, -998.57, -98.99-0.10)
        PointCamAtCoord(cameras.facial,  408.78, -998.57, -98.99+0.70)
        PointCamAtCoord(cameras.shoes,  408.78, -998.57, -98.99-0.70)
        PointCamAtCoord(cameras.skin,  408.78, -998.57, -98.99+0.70)

    playerSex = sex
    DoScreenFadeOut(2000)
    Citizen.Wait(3000)
    -- Set Preset Clothing
    if sex then
        currentSetting.playerModel          = "mp_m_freemode_01"
        currentSetting.clothing.pants.one   = 0
        currentSetting.clothing.pants.two   = 0
        currentSetting.clothing.shoes.one   = 1
        currentSetting.clothing.shoes.two   = 0
        currentSetting.clothing.torso.one   = 0
        currentSetting.clothing.torso.two   = 0
        currentSetting.clothing.tshirt.one  = -1
        currentSetting.clothing.arms.one    = 0
        currentSetting.clothing.arms.two    = 0
    else
        currentSetting.playerModel          = "mp_f_freemode_01"
        currentSetting.clothing.pants.one   = 0
        currentSetting.clothing.pants.two   = 0
        currentSetting.clothing.shoes.one   = 1
        currentSetting.clothing.shoes.two   = 0
        currentSetting.clothing.torso.one   = 0
        currentSetting.clothing.torso.two   = 0
        currentSetting.clothing.tshirt.one  = -1
        currentSetting.clothing.arms.one   = 4
        currentSetting.clothing.arms.two    = 0
    end
    RequestModel(currentSetting.playerModel)
    while not HasModelLoaded(currentSetting.playerModel) do
        Citizen.Wait(1)
    end
    SetPlayerModel(PlayerId(), currentSetting.playerModel)
    SetPedDefaultComponentVariation(PlayerPedId())
    SetEntityAsMissionEntity(PlayerPedId(), true, true)
    SetModelAsNoLongerNeeded(PlayerPedId())
    updateCharacter()
    local playerPed = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(playerPed)
    if not inShop then
        TaskClearLookAt(GetPlayerPed(-1))
        SetCamActive(cameras.accessories, true)
        RenderScriptCams(true, true, 500, true, true)
    end
    Citizen.Wait(3000)
    DoScreenFadeIn(2000)
    openingMenu()
end)

local adjustCamera = true

RegisterNetEvent('pw_base:charCreator:changeSkin')
AddEventHandler('pw_base:charCreator:changeSkin', function(data)
        if data.component == "mum" then
            currentSetting.skin.mom = tonumber(data.option)
            if not inShop then
                SetCamActive(cameras.facial, true)
            end
        elseif data.component == "dad" then
            currentSetting.skin.dad = tonumber(data.option)
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "skinmix" then
            currentSetting.skin.skinmix = tonumber(data.option) / 10 + 0.0
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "age" then
            currentSetting.skin.age.style = tonumber(data.option)
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "ageop" then
            currentSetting.skin.age.opacity = tonumber(data.option) / 10 + 0.0
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "nosewidth" then
            currentSetting.skin.nose.width = tonumber(data.option)
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "noselength" then
            currentSetting.skin.nose.length = tonumber(data.option)
            if not inShop then
                SetCamActive(cameras.nose, true)
            end            
        elseif data.component == "nosebonetwist" then
            currentSetting.skin.nose.bone_twist = tonumber(data.option)
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "nosepeakheight" then
            currentSetting.skin.nose.peak_height = tonumber(data.option)
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "nosepeaklowering" then
            currentSetting.skin.nose.peak_lowering = tonumber(data.option)
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "cwidth" then
            currentSetting.skin.cheek.width = tonumber(data.option)
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "chigh" then
            currentSetting.skin.cheek.high = tonumber(data.option)
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "cbwidth" then
            currentSetting.skin.cheek.bonewidth = tonumber(data.option)
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "complexionStyle" then
            currentSetting.skin.complexion.style = tonumber(data.option)
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "complexionOpacity" then
            currentSetting.skin.complexion.opacity = tonumber(data.option) / 10 + 0.0
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "blemishesStyle" then
            currentSetting.skin.blemishes.style = tonumber(data.option)
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "blemishesOpacity" then
            currentSetting.skin.blemishes.opacity = tonumber(data.option) / 10 + 0.0
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "jlength" then
            currentSetting.skin.jaw.length = tonumber(data.option)
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "jwidth" then
            currentSetting.skin.jaw.width = tonumber(data.option) 
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "clowering" then
            currentSetting.skin.chin.lowering = tonumber(data.option)
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "chinwidth" then
            currentSetting.skin.chin.width = tonumber(data.option)
            if not inShop then
                SetCamActive(cameras.nose, true)
            end            
        elseif data.component == "chinlength" then
            currentSetting.skin.chin.length = tonumber(data.option)
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "chole" then
            currentSetting.skin.chin.hole = tonumber(data.option)
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "neck" then
            currentSetting.skin.neck = tonumber(data.option)
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "eyebrowhigh" then 
            currentSetting.skin.eyebrow.high = tonumber(data.option)
            currentSetting.facial.eyebrow.opacity = currentSetting.facial.eyebrow.opacity or 0.5
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "hairstyle" then
            currentSetting.facial.hair.style = tonumber(data.option)
        elseif data.component == "haircolor1" then
            currentSetting.facial.hair.color1 = tonumber(data.option)
        elseif data.component == "haircolor2" then
            currentSetting.facial.hair.color2 = tonumber(data.option)
        elseif data.component == "eyebrowstyle" then
            currentSetting.facial.eyebrow.style = tonumber(data.option)
        elseif data.component == "eyebrowopacity" then
            currentSetting.facial.eyebrow.opacity = (tonumber(data.option) / 10)
        elseif data.component == "beardstyle" then
            if currentSetting.accessories.chain.one == 5 or currentSetting.accessories.chain.one == 7 or currentSetting.accessories.chain.one == 9 or currentSetting.accessories.chain.one == 13 or currentSetting.accessories.chain.one == 14 or currentSetting.accessories.chain.one == 15 or currentSetting.accessories.chain.one == 57 or currentSetting.accessories.chain.one == 58 or currentSetting.accessories.chain.one == 59 or currentSetting.accessories.chain.one == 60 or currentSetting.accessories.chain.one == 61 or currentSetting.accessories.chain.one == 62 then
                currentSetting.accessories.chain.one = -1
                currentSetting.accessories.chain.two = -1
            end
            currentSetting.facial.beard.style = tonumber(data.option)
        elseif data.component == "beardopacity" then
            currentSetting.facial.beard.opacity = (tonumber(data.option) / 10) + 0.0
        elseif data.component == "custombeard" then
            currentSetting.accessories.chain.one = (data.option - 1000)
            currentSetting.accessories.chain.two = 0
        elseif data.component == "eyebrowcolor1" then
            currentSetting.facial.eyebrow.color1 = tonumber(data.option)
        elseif data.component == "eyebrowcolor2" then
            currentSetting.facial.eyebrow.color2 = tonumber(data.option)
        elseif data.component == "beardcolor1" then
            currentSetting.facial.beard.color1 = tonumber(data.option)
        elseif data.component == "beardcolor2" then
            currentSetting.facial.beard.color2 = tonumber(data.option)
        elseif data.component == "lipstickstyle" then
            currentSetting.facial.lipstick.style = tonumber(data.option)
        elseif data.component == "lipstickopacity" then
            currentSetting.facial.lipstick.opacity = (tonumber(data.option) / 10) + 0.0
        elseif data.component == "lipstickcolor1" then
            currentSetting.facial.lipstick.color1 = tonumber(data.option)
        elseif data.component == "lipstickcolor2" then
            currentSetting.facial.lipstick.color2 = tonumber(data.option)
        elseif data.component == "makeupstyle" then
            currentSetting.facial.makeup.style = tonumber(data.option)
        elseif data.component == "makeupopacity" then
            currentSetting.facial.makeup.opacity = (tonumber(data.option) / 10) + 0.0
        elseif data.component == "makeupcolor1" then
            currentSetting.facial.makeup.color1 = tonumber(data.option)
        elseif data.component == "makeupcolor2" then
            currentSetting.facial.makeup.color2 = tonumber(data.option)
        elseif data.component == "tshirt1" then
            currentSetting.clothing.tshirt.one = tonumber(data.option)
            currentSetting.clothing.tshirt.two = 0
            TriggerEvent('pw_base:charCreator:openClothingMenu')
        elseif data.component == "tshirt2" then
            currentSetting.clothing.tshirt.two = tonumber(data.option)
        elseif data.component == "torso1" then
            currentSetting.clothing.torso.one = tonumber(data.option)
            currentSetting.clothing.torso.two = 0
            TriggerEvent('pw_base:charCreator:openClothingMenu')
        elseif data.component == "torso2" then
            currentSetting.clothing.torso.two = tonumber(data.option)
        elseif data.component == "arms1" then
            currentSetting.clothing.arms.one = tonumber(data.option)
        elseif data.component == "arms2" then
            currentSetting.clothing.arms.two = tonumber(data.option)
        elseif data.component == "pants1" then
            currentSetting.clothing.pants.one = tonumber(data.option)
            currentSetting.clothing.pants.two = 0
            TriggerEvent('pw_base:charCreator:openClothingMenu')
        elseif data.component == "pants2" then
            currentSetting.clothing.pants.two = tonumber(data.option)
        elseif data.component == "shoes1" then
            currentSetting.clothing.shoes.one = tonumber(data.option)
            currentSetting.clothing.shoes.two = 0
            TriggerEvent('pw_base:charCreator:openClothingMenu')
            if not inShop then
                SetCamActive(cameras.shoes, true)
            end
        elseif data.component == "shoes2" then
            currentSetting.clothing.shoes.two = tonumber(data.option)
            TriggerEvent('pw_base:charCreator:openClothingMenu')
            if not inShop then
                SetCamActive(cameras.shoes, true)
            end          
        elseif data.component == "chain1" then
            currentSetting.accessories.chain.one = tonumber(data.option)
            currentSetting.accessories.chain.two = 0
            TriggerEvent('pw_base:charCreator:openAccessoriesMenu')
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "chain2" then
            currentSetting.accessories.chain.two = tonumber(data.option)
        elseif data.component == "bags1" then
            currentSetting.accessories.bags.one = tonumber(data.option)
            currentSetting.accessories.bags.two = 0
            TriggerEvent('pw_base:charCreator:openAccessoriesMenu')
        elseif data.component == "bags2" then
            currentSetting.accessories.bags.two = tonumber(data.option)
        elseif data.component == "bracelets1" then
            currentSetting.accessories.bracelets.one = tonumber(data.option)
            currentSetting.accessories.bracelets.two = 0
            TriggerEvent('pw_base:charCreator:openAccessoriesMenu')
            if not inShop then
                SetCamActive(cameras.arms.left, true)
            end            
        elseif data.component == "bracelets2" then
            currentSetting.accessories.bracelets.two = tonumber(data.option)
        elseif data.component == "helmet1" then
            currentSetting.accessories.helmet.one = tonumber(data.option)
            currentSetting.accessories.helmet.two = 0
            TriggerEvent('pw_base:charCreator:openAccessoriesMenu')
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "helmet2" then
            currentSetting.accessories.helmet.two = tonumber(data.option)
        elseif data.component == "ears1" then
            currentSetting.accessories.ears.one = tonumber(data.option)
            currentSetting.accessories.ears.two = 0
            TriggerEvent('pw_base:charCreator:openAccessoriesMenu')
            if not inShop then
                SetCamActive(cameras.ears, true)
            end            
        elseif data.component == "ears2" then
            currentSetting.accessories.ears.two = tonumber(data.option)
        elseif data.component == "glasses1" then
            currentSetting.accessories.glasses.one = tonumber(data.option)
            currentSetting.accessories.glasses.two = 0
            TriggerEvent('pw_base:charCreator:openAccessoriesMenu')
            if not inShop then
                SetCamActive(cameras.facial, true)
            end            
        elseif data.component == "glasses2" then
            currentSetting.accessories.glasses.two = tonumber(data.option)
        elseif data.component == "watches1" then
            currentSetting.accessories.watches.one = tonumber(data.option)
            currentSetting.accessories.watches.two = 0
            TriggerEvent('pw_base:charCreator:openAccessoriesMenu')
            if not inShop then
                SetCamActive(cameras.arms.right, true)
            end            
        elseif data.component == "watches2" then
            currentSetting.accessories.watches.two = tonumber(data.option)
        elseif data.component == "model" then
            RequestModel(data.option)
            while not HasModelLoaded(data.option) do
                Citizen.Wait(1)
            end
            SetPlayerModel(PlayerId(), data.option)
            SetPedDefaultComponentVariation(PlayerPedId())
            SetEntityAsMissionEntity(PlayerPedId(), true, true)
            SetModelAsNoLongerNeeded(PlayerPedId())
            currentSetting.playerModel = data.option
            local playerPed = GetPlayerPed(-1)
            if not inShop then
                SetEntityHeading(playerPed, tonumber(271.38))
                FreezeEntityPosition(playerPed, true)
            end
            if(currentSetting.playerModel ~= "mp_m_freemode_01" and currentSetting.playerModel ~= "mp_f_freemode_01") then
                --SetPedRandomComponentVariation(GetPlayerPed(-1), true)    
            end
        end
        if(currentSetting.playerModel ~= "mp_m_freemode_01" and currentSetting.playerModel ~= "mp_f_freemode_01") then
            SetPedDefaultComponentVariation(PlayerPedId())
        else
            updateCharacter()
        end
end)

RegisterNetEvent('pw_base:charCreator:openAccessoriesMenu')
AddEventHandler('pw_base:charCreator:openAccessoriesMenu', function()
    local playerPed = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(playerPed)
    if not inShop then
        TaskLookAtCoord(playerPed, 410.3, -998.54, -98.99+0.20, -1, 0, 2)
        TaskStandStill(playerPed, -1)
        FreezeEntityPosition(playerPed, true)
        SetCamActive(cameras.accessories, true)
    end

    local slider, decals1, bproof1, chain1, bags1, helmet1, glasses1, watches1, bracelets1, mask1, ears1 = {}, GetNumberOfPedDrawableVariations(playerPed, 10), GetNumberOfPedDrawableVariations(playerPed, 9), GetNumberOfPedDrawableVariations(playerPed, 7), GetNumberOfPedDrawableVariations(playerPed, 5), GetNumberOfPedPropDrawableVariations(playerPed, 0), GetNumberOfPedPropDrawableVariations(playerPed, 1), GetNumberOfPedPropDrawableVariations(playerPed, 6), GetNumberOfPedPropDrawableVariations(playerPed, 7), GetNumberOfPedDrawableVariations(playerPed, 1), GetNumberOfPedPropDrawableVariations(playerPed, 1)
    local decals2, bproof2, chain2, bags2, helmet2, glasses2, watches2, bracelets2, mask2, ears2 = GetNumberOfPedTextureVariations(playerPed, 10, currentSetting.accessories.decals.one), GetNumberOfPedTextureVariations(playerPed, 9, currentSetting.accessories.bproof.one), GetNumberOfPedTextureVariations(playerPed, 7, currentSetting.accessories.chain.one), GetNumberOfPedTextureVariations(playerPed, 5, currentSetting.accessories.bags.one), GetNumberOfPedPropTextureVariations(playerPed, 0, currentSetting.accessories.helmet.one), GetNumberOfPedPropTextureVariations(playerPed, 1, currentSetting.accessories.glasses.one), GetNumberOfPedPropTextureVariations(playerPed, 6, currentSetting.accessories.watches.one), GetNumberOfPedPropTextureVariations(playerPed, 7, currentSetting.accessories.bracelets.one), GetNumberOfPedTextureVariations(playerPed, 1, currentSetting.accessories.mask.one), GetNumberOfPedPropTextureVariations(playerPed, 1, currentSetting.accessories.ears.one)
    local decals1tbl, bproof1tbl, chain1tbl, bags1tbl, helmet1tbl, glasses1tbl, watches1tbl, bracelets1tbl, mask1tbl, ears1tbl, decals2tbl, bproof2tbl, chain2tbl, bags2tbl, helmet2tbl, glasses2tbl, watches2tbl, bracelets2tbl, mask2tbl, ears2tbl = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}

    --------- BAGS
    table.insert(bags1tbl, { ['label'] = "No Bag ("..(bags1).." Avaliable)", ['data'] = { ['component'] = "bags1", ['option'] =  -1 }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    for i = 1, bags1 do
        table.insert(bags1tbl, { ['label'] = "Bag #"..(i).." ("..bags1.." Avaliable)", ['data'] = { ['component'] = "bags1", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    table.insert(bags2tbl, { ['label'] = "No Style ("..(bags2).." Avaliable)", ['data'] = { ['component'] = "bags2", ['option'] =  -1 }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    for i = 1, bags2 do
        table.insert(bags2tbl, { ['label'] = "Style #"..(i).." ("..bags2.." Avaliable)", ['data'] = { ['component'] = "bags2", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    --------- BRACELETS
    table.insert(bracelets1tbl, { ['label'] = "No Bracelet ("..(bracelets1).." Avaliable)", ['data'] = { ['component'] = "bracelets1", ['option'] =  -1 }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    for i = 1, bracelets1 do
        table.insert(bracelets1tbl, { ['label'] = "Bracelet #"..(i).." ("..bracelets1.." Avaliable)", ['data'] = { ['component'] = "bracelets1", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    table.insert(bracelets2tbl, { ['label'] = "No Style ("..(bracelets2).." Avaliable)", ['data'] = { ['component'] = "bracelets2", ['option'] =  -1 }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    for i = 1, bracelets2 do
        table.insert(bracelets2tbl, { ['label'] = "Style #"..(i).." ("..bracelets2.." Avaliable)", ['data'] = { ['component'] = "bracelets2", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    --------- CHAINS
    table.insert(chain1tbl, { ['label'] = "No Chain ("..(chain1-#skinOptions.facial.custombeards).." Avaliable)", ['data'] = { ['component'] = "chain1", ['option'] =  -1 }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    for i = 1, chain1 do
        if (i-1) ~= 5 and (i-1) ~= 7 and (i-1) ~= 9 and (i-1) ~= 13 and (i-1) ~= 14 and (i-1) ~= 15 and (i-1) ~= 57 and (i-1) ~= 58 and (i-1) ~= 59 and (i-1) ~= 60 and (i-1) ~= 61 and (i-1) ~= 62 then 
            table.insert(chain1tbl, { ['label'] = "Chain #"..(i).." ("..(chain1-#skinOptions.facial.custombeards).." Avaliable)", ['data'] = { ['component'] = "chain1", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
        end
    end

    table.insert(chain2tbl, { ['label'] = "No Style ("..chain2.." Avaliable)", ['data'] = { ['component'] = "chain2", ['option'] =  -1 }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    for i = 1, chain2 do
        table.insert(chain2tbl, { ['label'] = "Style #"..(i).." ("..chain2.." Avaliable)", ['data'] = { ['component'] = "chain2", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    --------- EARS
    table.insert(ears1tbl, { ['label'] = "None ("..(ears1).." Avaliable)", ['data'] = { ['component'] = "ears1", ['option'] =  -1 }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    for i = 1, ears1 do
        table.insert(ears1tbl, { ['label'] = "Type #"..(i).." ("..(ears1).." Avaliable)", ['data'] = { ['component'] = "ears1", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    table.insert(ears2tbl, { ['label'] = "No Style ("..ears2.." Avaliable)", ['data'] = { ['component'] = "ears2", ['option'] =  -1 }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    for i = 1, ears2 do
        table.insert(ears2tbl, { ['label'] = "Style #"..(i).." ("..ears2.." Avaliable)", ['data'] = { ['component'] = "ears2", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    --------- GLASSES
    table.insert(glasses1tbl, { ['label'] = "None ("..(glasses1).." Avaliable)", ['data'] = { ['component'] = "glasses1", ['option'] =  -1 }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    for i = 1, glasses1 do
        table.insert(glasses1tbl, { ['label'] = "Type #"..(i).." ("..(glasses1).." Avaliable)", ['data'] = { ['component'] = "glasses1", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    table.insert(glasses2tbl, { ['label'] = "No Style ("..glasses2.." Avaliable)", ['data'] = { ['component'] = "glasses2", ['option'] =  -1 }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    for i = 1, glasses2 do
        table.insert(glasses2tbl, { ['label'] = "Style #"..(i).." ("..glasses2.." Avaliable)", ['data'] = { ['component'] = "glasses2", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    --------- HELMETS
    table.insert(helmet1tbl, { ['label'] = "No Helmet ("..(helmet1).." Avaliable)", ['data'] = { ['component'] = "helmet1", ['option'] =  -1 }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    for i = 1, helmet1 do
        table.insert(helmet1tbl, { ['label'] = "Helmet #"..(i).." ("..helmet1.." Avaliable)", ['data'] = { ['component'] = "helmet1", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    table.insert(helmet2tbl, { ['label'] = "No Style ("..(helmet2).." Avaliable)", ['data'] = { ['component'] = "helmet2", ['option'] =  -1 }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    for i = 1, helmet2 do
        table.insert(helmet2tbl, { ['label'] = "Style #"..(i).." ("..helmet2.." Avaliable)", ['data'] = { ['component'] = "helmet2", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    --------- WATCHES
    table.insert(watches1tbl, { ['label'] = "None ("..(watches1).." Avaliable)", ['data'] = { ['component'] = "watches1", ['option'] =  -1 }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    for i = 1, watches1 do
        table.insert(watches1tbl, { ['label'] = "Type #"..(i).." ("..(watches1).." Avaliable)", ['data'] = { ['component'] = "watches1", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    table.insert(watches2tbl, { ['label'] = "No Style ("..watches2.." Avaliable)", ['data'] = { ['component'] = "watches2", ['option'] =  -1 }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    for i = 1, watches2 do
        table.insert(watches2tbl, { ['label'] = "Style #"..(i).." ("..watches2.." Avaliable)", ['data'] = { ['component'] = "watches2", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    if bags1 > 0 then
        table.insert(slider, { ['label'] = "Bag" })
        table.insert(slider, { ['label'] = "Primary", ['options'] = bags1tbl, ['default'] = currentSetting.accessories.bags.one })
        if currentSetting.accessories.bags.one ~= -1 then
            table.insert(slider, { ['label'] = "Secondary", ['options'] = bags2tbl, ['default'] = currentSetting.accessories.bags.two })
        end
    end

    if bracelets1 > 0 then
        table.insert(slider, { ['label'] = "Bracelets" })
        table.insert(slider, { ['label'] = "Primary", ['options'] = bracelets1tbl, ['default'] = currentSetting.accessories.bracelets.one })
        if currentSetting.accessories.bracelets.one ~= -1 then
            table.insert(slider, { ['label'] = "Secondary", ['options'] = bracelets2tbl, ['default'] = currentSetting.accessories.bracelets.two })
        end
    end
    
    if chain1 > 0 then
        if currentSetting.accessories.chain.one == 5 or currentSetting.accessories.chain.one == 7 or currentSetting.accessories.chain.one == 9 or currentSetting.accessories.chain.one == 13 or currentSetting.accessories.chain.one == 14 or currentSetting.accessories.chain.one == 15 or currentSetting.accessories.chain.one == 57 or currentSetting.accessories.chain.one == 58 or currentSetting.accessories.chain.one == 59 or currentSetting.accessories.chain.one == 60 or currentSetting.accessories.chain.one == 61 or currentSetting.accessories.chain.one == 62 then
            table.insert(slider, { ['label'] = "Chain<br><small><span class='text-danger'>Unavaliable with Custom Beard</span></small>" })
        else
            table.insert(slider, { ['label'] = "Chain" })
            table.insert(slider, { ['label'] = "Primary", ['options'] = chain1tbl, ['default'] = currentSetting.accessories.chain.one })
            if currentSetting.accessories.chain.one ~= -1 then
                table.insert(slider, { ['label'] = "Secondary", ['options'] = chain2tbl, ['default'] = currentSetting.accessories.chain.two })
            end
        end
    end

    if ears1 > 0 then
        table.insert(slider, { ['label'] = "Ear Accessories" })
        table.insert(slider, { ['label'] = "Primary", ['options'] = ears1tbl, ['default'] = currentSetting.accessories.ears.one })
        if currentSetting.accessories.ears.one ~= -1 then
            table.insert(slider, { ['label'] = "Secondary", ['options'] = ears2tbl, ['default'] = currentSetting.accessories.ears.two })
        end
    end

    if glasses1 > 0 then
        table.insert(slider, { ['label'] = "Glasses" })
        table.insert(slider, { ['label'] = "Primary", ['options'] = glasses1tbl, ['default'] = currentSetting.accessories.glasses.one })
        if currentSetting.accessories.glasses.one ~= -1 then
            table.insert(slider, { ['label'] = "Secondary", ['options'] = glasses2tbl, ['default'] = currentSetting.accessories.glasses.two })
        end
    end

    if helmet1 > 0 then
        table.insert(slider, { ['label'] = "Helmets" })
        table.insert(slider, { ['label'] = "Primary", ['options'] = helmet1tbl, ['default'] = currentSetting.accessories.helmet.one })
        if currentSetting.accessories.helmet.one ~= -1 then
            table.insert(slider, { ['label'] = "Secondary", ['options'] = helmet2tbl, ['default'] = currentSetting.accessories.helmet.two })
        end
    end
    
    if watches1 > 0 then
        table.insert(slider, { ['label'] = "Watches" })
        table.insert(slider, { ['label'] = "Primary", ['options'] = watches1tbl, ['default'] = currentSetting.accessories.watches.one })
        if currentSetting.accessories.watches.one ~= -1 then
            table.insert(slider, { ['label'] = "Secondary", ['options'] = watches2tbl, ['default'] = currentSetting.accessories.watches.two })
        end
    end

    if inShop then
        TriggerEvent('pw_interact:generateSkinChangeMenu', "Accessories Customization", slider, {['autorefresh'] = true, ['moveMouse'] = true, ['allowSwapKey'] = true, ['return'] = { trigger = "pw_base:charCreator:frontMenuShop", triggertype = "client"}})
    else
        TriggerEvent('pw_interact:generateSkinChangeMenu', "Accessories Customization", slider, {['preventClose'] = true, ['autorefresh'] = true, ['camera'] = "accessories", ['allowSwapKey'] = true, ['return'] = { trigger = "pw_base:charCreator:frontMenu", triggertype = "client"}})
    end
end)

RegisterNetEvent('pw_base:charCreator:openClothingMenu')
AddEventHandler('pw_base:charCreator:openClothingMenu', function()
    revertSettings = currentSetting
    local playerPed = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(playerPed)
    if not inShop then
        FreezeEntityPosition(playerPed, true)
        TaskLookAtCoord(playerPed, 410.3, -998.54, -98.99+0.20, -1, 0, 2)
        TaskStandStill(playerPed, -1)
        SetCamActive(cameras.clothing, true)
    end
    
    local slider, t1menu, to1menu, a1menu, p1menu, s1menu, t2menu, to2menu, a2menu, p2menu, s2menu = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
    local tshirt1, torso1, arms1, pants1, shoes1 = GetNumberOfPedDrawableVariations(playerPed, 8), GetNumberOfPedDrawableVariations(playerPed, 11), GetNumberOfPedDrawableVariations(playerPed, 3), GetNumberOfPedDrawableVariations(playerPed, 4), GetNumberOfPedDrawableVariations(playerPed, 6)   
    local tshirt2, torso2, arms2, pants2, shoes2 = GetNumberOfPedTextureVariations(playerPed, 8, currentSetting.clothing.tshirt.one), GetNumberOfPedTextureVariations(playerPed, 11, currentSetting.clothing.torso.one), 10, GetNumberOfPedTextureVariations(playerPed, 4, currentSetting.clothing.pants.one), GetNumberOfPedTextureVariations(playerPed, 6, currentSetting.clothing.shoes.one)
    
        table.insert(t1menu, { ['label'] = "None ("..tshirt1.." Shirts)", ['label'] = "None", ['data'] = { ['component'] = "tshirt1", ['option'] =  -1 }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    for i = 1, tshirt1 do
        table.insert(t1menu, { ['label'] = "Shirt #"..(i).." ("..tshirt1.." Avaliable)", ['data'] = { ['component'] = "tshirt1", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

        table.insert(t2menu, { ['label'] = "None ("..tshirt2.." Styles)", ['data'] = { ['component'] = "tshirt2", ['option'] =  -1 }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    for i = 1, tshirt2 do
        table.insert(t2menu, { ['label'] = "Style #"..(i).." ("..tshirt2.." Avaliable)", ['data'] = { ['component'] = "tshirt2", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

        table.insert(to1menu, { ['label'] = "None ("..torso1.." Avaliable)", ['data'] = { ['component'] = "torso1", ['option'] =  -1 }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    for i = 1, torso1 do
        table.insert(to1menu, { ['label'] = "Torso #"..(i).." ("..torso1.." Avaliable)", ['data'] = { ['component'] = "torso1", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

        table.insert(to2menu, {['label'] = "None ("..torso2.." Avaliable)", ['label'] = "None", ['data'] = { ['component'] = "torso2", ['option'] =  -1 }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    for i = 1, torso2 do
        table.insert(to2menu, {['label'] = "Style #"..(i).." ("..torso2.." Avaliable)", ['data'] = { ['component'] = "torso2", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for i = 1, arms1 do
        table.insert(a1menu, {['label'] = "Style 1 #"..(i-1).." ("..arms1.." Avaliable)", ['data'] = { ['component'] = "arms1", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for i = 1, arms2 do
        table.insert(a2menu, {['label'] = "Style 2 #"..(i).." ("..arms2.." Avaliable)", ['data'] = { ['component'] = "arms2", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for i = 1, pants1 do
        table.insert(p1menu, {['label'] = "Pants #"..(i).." ("..pants1.." Avaliable)", ['data'] = { ['component'] = "pants1", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for i = 1, pants2 do
        table.insert(p2menu, {['label'] = "Style #"..(i).." ("..pants2.." Avaliable)", ['data'] = { ['component'] = "pants2", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for i = 1, shoes1 do
        if i ~= 14 and i ~= 34 then
            table.insert(s1menu, {['label'] = "Shoes #"..(i).." ("..(shoes1-2).." Avaliable)", ['data'] = { ['component'] = "shoes1", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
        end
    end

    for i = 1, shoes2 do
        table.insert(s2menu, {['label'] = "Style #"..(i).." ("..shoes2.." Avaliable)", ['data'] = { ['component'] = "shoes2", ['option'] =  (i-1) }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    if torso1 > 0 then
        table.insert(slider, { ['label'] = "Torso" })
        table.insert(slider, { ['label'] = "Primary", ['options'] = to1menu, ['default'] = currentSetting.clothing.torso.one })
        if currentSetting.clothing.torso.one ~= -1 then
            table.insert(slider, { ['label'] = "Secondary", ['options'] = to2menu })
        end
    end

    if tshirt1 > 0 then
        if(currentSetting.playerModel == "mp_m_freemode_01" or currentSetting.playerModel == "mp_f_freemode_01") then
            table.insert(slider, { ['label'] = "T-Shirt" })
        else
            table.insert(slider, { ['label'] = "Accessories" })
        end
        table.insert(slider, { ['label'] = "Primary", ['options'] = t1menu, ['default'] = currentSetting.clothing.tshirt.one })
        if currentSetting.clothing.tshirt.one ~= -1 then
            table.insert(slider, { ['label'] = "Secondary", ['options'] = t2menu })
        end
    end

    if arms1 > 0 then
        if(currentSetting.playerModel == "mp_m_freemode_01" or currentSetting.playerModel == "mp_f_freemode_01") then
            table.insert(slider, { ['label'] = "Arms" })
        else
            table.insert(slider, { ['label'] = "T-Shirt" })
        end
        table.insert(slider, { ['label'] = "Primary", ['options'] = a1menu })
        table.insert(slider, { ['label'] = "Secondary", ['options'] = a2menu, ['default'] = currentSetting.clothing.arms.two })
    end

    if pants1 > 0 then
        table.insert(slider, { ['label'] = "Pants" })
        table.insert(slider, { ['label'] = "Primary", ['options'] = p1menu, ['default'] = currentSetting.clothing.pants.one })
        table.insert(slider, { ['label'] = "Secondary", ['options'] = p2menu, ['default'] = currentSetting.clothing.pants.two })
    end

    if shoes1 > 0 then
        table.insert(slider, { ['label'] = "Footware" })
        table.insert(slider, { ['label'] = "Primary", ['options'] = s1menu, ['default'] = currentSetting.clothing.shoes.one })
        table.insert(slider, { ['label'] = "Secondary", ['options'] = s2menu, ['default'] = currentSetting.clothing.shoes.two })
    end

    if inShop then
        TriggerEvent('pw_interact:generateSkinChangeMenu', "Clothing Customization", slider, {['autorefresh'] = true, ['moveMouse'] = true, ['allowSwapKey'] = true, ['allowHandsUp'] = true, ['return'] = { trigger = "pw_base:charCreator:frontMenuShop", triggertype = "client", data = revertSettings}})
    else
        TriggerEvent('pw_interact:generateSkinChangeMenu', "Clothing Customization", slider, {['preventClose'] = true, ['autorefresh'] = true, ['camera'] = "clothing", ['allowSwapKey'] = true, ['allowHandsUp'] = true, ['return'] = { trigger = "pw_base:charCreator:frontMenu", triggertype = "client"}})
    end

end)

RegisterNUICallback("rotateCharacter", function(data, cb)
    local playerPed = GetPlayerPed(-1)
    local playerHeading = GetEntityHeading(playerPed)
    SetEntityHeading(playerPed, playerHeading+180.0)
end)

RegisterNUICallback("handsUpCharacter", function(data, cb)
    local playerPed = GetPlayerPed(-1)
    
    if isHandsUp then
        ClearPedTasksImmediately(playerPed)
        TaskLookAtCoord(playerPed, 410.3, -998.54, -98.99+0.20, -1, 0, 2)
        TaskStandStill(playerPed, -1)
        isHandsUp = false
    else
        TaskHandsUp(playerPed, -1, -1, -1, false)
        isHandsUp = true
    end
end)

RegisterNUICallback("resetCamera", function(data, cb)
    Citizen.CreateThread(function()
        if (data) then
            if not inShop then
                SetCamActive(cameras[data.cameraPos], true)
            end
        end
    end)
end)

RegisterNetEvent('pw_base:charCreator:openHairMenu1')
AddEventHandler('pw_base:charCreator:openHairMenu1', function()
    revertSettings = currentSetting
    local slider, hairstyle, haircolors1, haircolors2, eyebrowstyle, eyebrowopacity, beardstyle, beardopacity, eyebrowcolor1, eyebrowcolor2, beardcolor1, beardcolor2 = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
    for k, v in pairs(skinOptions.facial.hair.style) do
        if (playerSex and v ~= 23) or (not playerSex and v ~= 24) then
            table.insert(hairstyle, { ['label'] = "Style #"..v, ['data'] = { ['component'] = "hairstyle", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
        end
    end

    for k, v in pairs(skinOptions.colors) do
        table.insert(haircolors1, { ['label'] = v, ['data'] = { ['component'] = "haircolor1", ['option'] = k }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.colors) do
        table.insert(haircolors2, { ['label'] = v, ['data'] = { ['component'] = "haircolor2", ['option'] = k }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.facial.eyebrow.style) do
        table.insert(eyebrowstyle, { ['label'] = "Style #"..v, ['data'] = { ['component'] = "eyebrowstyle", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.facial.eyebrow.opacity) do
        table.insert(eyebrowopacity, { ['label'] = (v*10).."%", ['data'] = { ['component'] = "eyebrowopacity", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.facial.beard.style) do
        table.insert(beardstyle, { ['label'] = "Standard Style #"..(v), ['data'] = { ['component'] = "beardstyle", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.facial.custombeards) do
        table.insert(beardstyle, { ['label'] = "Custom Style #"..(k), ['data'] = { ['component'] = "custombeard", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.facial.beard.opacity) do
        table.insert(beardopacity, { ['label'] = (v*10).."%", ['data'] = { ['component'] = "beardopacity", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.colors) do
        table.insert(eyebrowcolor1, { ['label'] = v, ['data'] = { ['component'] = "eyebrowcolor1", ['option'] = k }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.colors) do
        table.insert(eyebrowcolor2, { ['label'] = v, ['data'] = { ['component'] = "eyebrowcolor2", ['option'] = k }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.colors) do
        table.insert(beardcolor1, { ['label'] = v, ['data'] = { ['component'] = "beardcolor1", ['option'] = k }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end
    
    for k, v in pairs(skinOptions.colors) do
        table.insert(beardcolor2, { ['label'] = v, ['data'] = { ['component'] = "beardcolor2", ['option'] = k }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    table.insert(slider, { ['label'] = "Hair Style" })
    table.insert(slider, { ['label'] = "Style",     ['options'] = hairstyle,        ['default'] = currentSetting.facial.hair.style or -1 })
    table.insert(slider, { ['label'] = "Color 1",   ['options'] = haircolors1,      ['default'] = currentSetting.facial.hair.color1 or 0 })
    table.insert(slider, { ['label'] = "Color 2",   ['options'] = haircolors2,      ['default'] = currentSetting.facial.hair.color2 or 0 })
    table.insert(slider, { ['label'] = "Eyebrows" })
    table.insert(slider, { ['label'] = "Style",     ['options'] = eyebrowstyle,     ['default'] = currentSetting.facial.eyebrow.style or -1 })
    table.insert(slider, { ['label'] = "Opacity",   ['options'] = eyebrowopacity,   ['default'] = (currentSetting.facial.eyebrow.opacity * 10) })
    table.insert(slider, { ['label'] = "Color 1",   ['options'] = eyebrowcolor1,    ['default'] = currentSetting.facial.eyebrow.color1 })
    table.insert(slider, { ['label'] = "Color 2",   ['options'] = eyebrowcolor2,    ['default'] = currentSetting.facial.eyebrow.color2 })
    table.insert(slider, { ['label'] = "Beard<br><small>Custom Type Beards will remove Chain</small>" })
    table.insert(slider, { ['label'] = "Opacity",   ['options'] = beardopacity,     ['default'] = (currentSetting.facial.beard.opacity * 10) })
    table.insert(slider, { ['label'] = "Style",     ['options'] = beardstyle,       ['default'] = currentSetting.facial.beard.style })
    table.insert(slider, { ['label'] = "Color 1",   ['options'] = beardcolor1,      ['default'] = currentSetting.facial.beard.color1 })
    table.insert(slider, { ['label'] = "Color 2",   ['options'] = beardcolor2,      ['default'] = currentSetting.facial.beard.color2 })
    TriggerEvent('pw_interact:generateSkinChangeMenu', "Facial Customization", slider, {['autorefresh'] = true, ['moveMouse'] = true, ['return'] = { trigger = "pw_base:charCreator:openHairMenu", triggertype = "client", data = revertSettings}})
end)

RegisterNetEvent('pw_base:charCreator:openHairMenu')
AddEventHandler('pw_base:charCreator:openHairMenu', function(currentStyle)
    if currentStyle == nil then
        currentStyle = currentSetting
    end
    local menu = {}
    table.insert(menu, { ['label'] = "Change Hair Style", ['action'] = "pw_base:charCreator:openHairMenu1", ['triggertype'] = "client", ['color'] = "primary" })
    table.insert(menu, { ['label'] = "Save", ['action'] = "pw_base:charCreator:saveHairandPurchase", ['triggertype'] = "client", ['color'] = "success" })
    table.insert(menu, { ['label'] = "Cancel", ['action'] = "pw_base:charCreator:revertSettings", ['triggertype'] = "client", ['value'] = currentStyle, ['color'] = "danger" })
    TriggerEvent('pw_interact:generateMenu', menu, "Barbers", { {['method'] = "client", ['trigger'] = "pw_base:charCreator:revertSettings", ['data'] = currentStyle } }, false, {['preventClose'] = true})
end)

RegisterNetEvent('pw_base:charCreator:saveHairandPurchase')
AddEventHandler('pw_base:charCreator:saveHairandPurchase', function()
    local hair = { ['hair'] = {}, ['eyebrow'] = {}, ['beard'] = {}}
    hair.hair.style = currentSetting.facial.hair.style
    hair.hair.color1 = currentSetting.facial.hair.color1
    hair.hair.color2 = currentSetting.facial.hair.color2
    hair.eyebrow.style = currentSetting.facial.eyebrow.style
    hair.eyebrow.opacity = currentSetting.facial.eyebrow.opacity
    hair.eyebrow.color1 = currentSetting.facial.eyebrow.color1
    hair.eyebrow.color2 = currentSetting.facial.eyebrow.color2
    hair.beard.opacity = currentSetting.facial.beard.opacity
    hair.beard.style = currentSetting.facial.beard.style
    hair.beard.color1 = currentSetting.facial.beard.color1
    hair.beard.color2 = currentSetting.facial.beard.color2
    TriggerServerEvent('pw_barber:server:purchaseHair', hair)
    TriggerEvent('pw_barbershop:leftStore')
end)

RegisterNetEvent('pw_base:charCreator:revertSettings')
AddEventHandler('pw_base:charCreator:revertSettings', function(data)
    print('reverting?')
        currentSetting = (data or revertSettings) or currentSetting
        updateCharacter()
end)

RegisterNetEvent('pw_base:charCreator:openFacialFeatures')
AddEventHandler('pw_base:charCreator:openFacialFeatures', function()
    local playerPed = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(playerPed)
    if not inShop then
        FreezeEntityPosition(playerPed, true)
        TaskLookAtCoord(playerPed, 409.5, -998.54, -98.99+0.70, -1, 0, 2)
        TaskStandStill(playerPed, -1)
        --tonumber(403.03), tonumber(-996.72), tonumber(-100.30) 408.78), tonumber(-998.57), tonumber(-98.99
        SetCamActive(cameras.facial, true)
    end

    local slider, hairstyle, haircolors1, haircolors2, eyebrowstyle, eyebrowopacity, beardstyle, beardopacity, eyebrowcolor1, eyebrowcolor2, beardcolor1, beardcolor2 = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
    local lipstick, lipstickopacity, lipstickcolor1, lipstickcolor2, makeup, makeupopacity, makeupcolor1, makeupcolor2 = {}, {}, {}, {}, {}, {}, {}, {}
    for k, v in pairs(skinOptions.colors) do
        table.insert(haircolors1, { ['label'] = v, ['data'] = { ['component'] = "haircolor1", ['option'] = k }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.colors) do
        table.insert(haircolors2, { ['label'] = v, ['data'] = { ['component'] = "haircolor2", ['option'] = k }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.facial.hair.style) do
        if (playerSex and v ~= 23) or (not playerSex and v ~= 24) then
            table.insert(hairstyle, { ['label'] = "Style #"..v, ['data'] = { ['component'] = "hairstyle", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
        end
    end

    for k, v in pairs(skinOptions.facial.eyebrow.style) do
        table.insert(eyebrowstyle, { ['label'] = "Style #"..v, ['data'] = { ['component'] = "eyebrowstyle", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.facial.eyebrow.opacity) do
        table.insert(eyebrowopacity, { ['label'] = (v*10).."%", ['data'] = { ['component'] = "eyebrowopacity", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.colors) do
        table.insert(eyebrowcolor1, { ['label'] = v, ['data'] = { ['component'] = "eyebrowcolor1", ['option'] = k }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.colors) do
        table.insert(eyebrowcolor2, { ['label'] = v, ['data'] = { ['component'] = "eyebrowcolor2", ['option'] = k }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.facial.beard.style) do
        table.insert(beardstyle, { ['label'] = "Standard Style #"..(v), ['data'] = { ['component'] = "beardstyle", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.facial.custombeards) do
        table.insert(beardstyle, { ['label'] = "Custom Style #"..(k), ['data'] = { ['component'] = "custombeard", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.facial.beard.opacity) do
        table.insert(beardopacity, { ['label'] = (v*10).."%", ['data'] = { ['component'] = "beardopacity", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.colors) do
        table.insert(beardcolor1, { ['label'] = v, ['data'] = { ['component'] = "beardcolor1", ['option'] = k }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end
    
    for k, v in pairs(skinOptions.colors) do
        table.insert(beardcolor2, { ['label'] = v, ['data'] = { ['component'] = "beardcolor2", ['option'] = k }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    ---- Lipstick
    for k, v in pairs(skinOptions.facial.lipstick.style) do
        table.insert(lipstick, { ['label'] = "Style #"..v, ['data'] = { ['component'] = "lipstickstyle", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.facial.lipstick.opacity) do
        table.insert(lipstickopacity, { ['label'] = (v*10).."%", ['data'] = { ['component'] = "lipstickopacity", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.colors) do
        table.insert(lipstickcolor1, { ['label'] = v, ['data'] = { ['component'] = "lipstickcolor1", ['option'] = k }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end
    
    for k, v in pairs(skinOptions.colors) do
        table.insert(lipstickcolor2, { ['label'] = v, ['data'] = { ['component'] = "lipstickcolor2", ['option'] = k }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    -- Makeup
    for k, v in pairs(skinOptions.facial.makeup.style) do
        table.insert(makeup, { ['label'] = "Style #"..v, ['data'] = { ['component'] = "makeupstyle", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.facial.makeup.opacity) do
        table.insert(makeupopacity, { ['label'] = (v*10).."%", ['data'] = { ['component'] = "makeupopacity", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.colors) do
        table.insert(makeupcolor1, { ['label'] = v, ['data'] = { ['component'] = "makeupcolor1", ['option'] = k }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end
    
    for k, v in pairs(skinOptions.colors) do
        table.insert(makeupcolor2, { ['label'] = v, ['data'] = { ['component'] = "makeupcolor2", ['option'] = k }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    table.insert(slider, { ['label'] = "Hair Style" })
    table.insert(slider, { ['label'] = "Style",     ['options'] = hairstyle,        ['default'] = currentSetting.facial.hair.style })
    table.insert(slider, { ['label'] = "Color 1",   ['options'] = haircolors1,      ['default'] = currentSetting.facial.hair.color1 })
    table.insert(slider, { ['label'] = "Color 2",   ['options'] = haircolors2,      ['default'] = currentSetting.facial.hair.color2 })
    table.insert(slider, { ['label'] = "Eyebrows" })
    table.insert(slider, { ['label'] = "Style",     ['options'] = eyebrowstyle,     ['default'] = currentSetting.facial.eyebrow.style })
    table.insert(slider, { ['label'] = "Opacity",   ['options'] = eyebrowopacity,   ['default'] = (currentSetting.facial.eyebrow.opacity * 10) })
    table.insert(slider, { ['label'] = "Color 1",   ['options'] = eyebrowcolor1,    ['default'] = currentSetting.facial.eyebrow.color1 })
    table.insert(slider, { ['label'] = "Color 2",   ['options'] = eyebrowcolor2,    ['default'] = currentSetting.facial.eyebrow.color2 })
    table.insert(slider, { ['label'] = "Beard<br><small>Custom Type Beards will remove Chain</small>" })
    table.insert(slider, { ['label'] = "Opacity",   ['options'] = beardopacity,     ['default'] = (currentSetting.facial.beard.opacity * 10) })
    table.insert(slider, { ['label'] = "Style",     ['options'] = beardstyle,       ['default'] = currentSetting.facial.beard.style })
    table.insert(slider, { ['label'] = "Color 1",   ['options'] = beardcolor1,      ['default'] = currentSetting.facial.beard.color1 })
    table.insert(slider, { ['label'] = "Color 2",   ['options'] = beardcolor2,      ['default'] = currentSetting.facial.beard.color2 })
    table.insert(slider, { ['label'] = "Lipstick" })
    table.insert(slider, { ['label'] = "Opacity",   ['options'] = lipstickopacity,      ['default'] = (currentSetting.facial.lipstick.opacity * 10) })
    table.insert(slider, { ['label'] = "Style",     ['options'] = lipstick,             ['default'] = currentSetting.facial.lipstick.style })
    table.insert(slider, { ['label'] = "Color 1",   ['options'] = lipstickcolor1,       ['default'] = currentSetting.facial.lipstick.color1 })
    table.insert(slider, { ['label'] = "Color 2",   ['options'] = lipstickcolor2,       ['default'] = currentSetting.facial.lipstick.color2 })
    table.insert(slider, { ['label'] = "Makeup" })
    table.insert(slider, { ['label'] = "Opacity",   ['options'] = makeupopacity,               ['default'] = (currentSetting.facial.makeup.opacity * 10) })
    table.insert(slider, { ['label'] = "Style",     ['options'] = makeup,        ['default'] = currentSetting.facial.makeup.style })
    table.insert(slider, { ['label'] = "Color 1",   ['options'] = makeupcolor1,         ['default'] = currentSetting.facial.makeup.color1 })
    table.insert(slider, { ['label'] = "Color 2",   ['options'] = makeupcolor2,         ['default'] = currentSetting.facial.makeup.color2 })
    Wait(100)
    TriggerEvent('pw_interact:generateSkinChangeMenu', "Facial Customization", slider, {['preventClose'] = true, ['autorefresh'] = true, ['camera'] = "facial", ['return'] = { trigger = "pw_base:charCreator:frontMenu", triggertype = "client"}})
end)

RegisterNetEvent('pw_base:charCreator:openSkinMenu')
AddEventHandler('pw_base:charCreator:openSkinMenu', function()
    local playerPed = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(playerPed)
    if not inShop then
        FreezeEntityPosition(playerPed, true)
        TaskLookAtCoord(playerPed, 409.5, -998.54, -98.99+0.70, -1, 0, 2)
        TaskStandStill(playerPed, -1)
        --tonumber(403.03), tonumber(-996.72), tonumber(-100.30) 408.78), tonumber(-998.57), tonumber(-98.99
        SetCamActive(cameras.skin, true)
    end

    local slider, mum, dad, mix, age, ageop, nwidth, npeak, nlength, nplower, nbone, chinwidth, eye1, eye2, neck, chigh, cbwidth, complexionstyle, jwidth, jlength, clowering, chinlength, cwidth, chole, complexionopacity, blemishesstyle, blemishesopacity = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}

    for k, v in pairs(skinOptions.skin.mom) do 
        table.insert(mum, { ['data'] = { ['component'] = "mum", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.dad) do 
        table.insert(dad, { ['data'] = { ['component'] = "dad", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.skinmix) do 
        table.insert(mix, { ['data'] = { ['component'] = "skinmix", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.age.style) do 
        table.insert(age, { ['label'] = "Style #"..v, ['data'] = { ['component'] = "age", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.age.opacity) do
        table.insert(ageop, { ['label'] = (v*10).."%", ['data'] = { ['component'] = "ageop", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.nose.width) do
        table.insert(nwidth, { ['data'] = { ['component'] = "nosewidth", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.nose.length) do
        table.insert(nlength, { ['data'] = { ['component'] = "noselength", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.nose.bone_twist) do
        table.insert(nbone, { ['data'] = { ['component'] = "nosebonetwist", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.nose.peak_height) do
        table.insert(npeak, { ['data'] = { ['component'] = "nosepeakheight", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.nose.peak_lowering) do
        table.insert(nplower, { ['data'] = { ['component'] = "nosepeaklowering", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.cheek.width) do
        table.insert(cwidth, { ['data'] = { ['component'] = "cwidth", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.cheek.high) do
        table.insert(chigh, { ['data'] = { ['component'] = "chigh", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.cheek.bonewidth) do
        table.insert(cbwidth, { ['data'] = { ['component'] = "cbwidth", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.complexion.style) do
        table.insert(complexionstyle, { ['label'] = "Style #"..v, ['data'] = { ['component'] = "complexionStyle", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.complexion.opacity) do
        table.insert(complexionopacity, { ['label'] = (v*10).."%", ['data'] = { ['component'] = "complexionOpacity", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.blemishes.style) do
        table.insert(blemishesstyle, { ['label'] = "Style #"..v, ['data'] = { ['component'] = "blemishesStyle", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.blemishes.opacity) do
        table.insert(blemishesopacity, { ['label'] = (v*10).."%", ['data'] = { ['component'] = "blemishesOpacity", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.jaw.length) do
        table.insert(jlength, { ['data'] = { ['component'] = "jlength", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.jaw.width) do
        table.insert(jwidth, { ['data'] = { ['component'] = "jwidth", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.chin.lowering) do
        table.insert(clowering, { ['data'] = { ['component'] = "clowering", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.chin.length) do
        table.insert(chinlength, { ['data'] = { ['component'] = "chinlength", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.chin.width) do
        table.insert(chinwidth, { ['data'] = { ['component'] = "chinwidth", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.chin.hole) do
        table.insert(chole, { ['data'] = { ['component'] = "chole", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.neck) do
        table.insert(neck, { ['data'] = { ['component'] = "neck", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    for k, v in pairs(skinOptions.skin.eyebrow.high) do
        table.insert(eye2, { ['data'] = { ['component'] = "eyebrowhigh", ['option'] = v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
    end

    table.insert(slider, { ['label'] = "Resemblences" })
    table.insert(slider, { ['label'] = "Mum's Resemblence", ['options'] = mum, ['default'] = currentSetting.skin.mom })
    table.insert(slider, { ['label'] = "Dad's Resemblence", ['options'] = dad, ['default'] = currentSetting.skin.dad })
    table.insert(slider, { ['label'] = "Resemblence Slider", ['type'] = "range", ['min'] = -9, ['max'] = 9, ['data'] = { ['component'] = "resemblence" }, ['default'] = (currentSetting.skin.resemblance * 10) })
    table.insert(slider, { ['label'] = "Skin Tone", ['options'] = mix, ['default'] = (currentSetting.skin.skinmix * 10) })
    table.insert(slider, { ['label'] = "Ageing" })
    table.insert(slider, { ['label'] = "Style", ['options'] = age, ['default'] = currentSetting.skin.age.style })
    table.insert(slider, { ['label'] = "Opacity", ['options'] = ageop, ['default'] = currentSetting.skin.age.opacity * 10 })
    table.insert(slider, { ['label'] = "Nose Features" })
    table.insert(slider, { ['label'] = "Width", ['options'] = nwidth, ['default'] = currentSetting.skin.nose.width })
    table.insert(slider, { ['label'] = "Length", ['options'] = nlength, ['default'] = currentSetting.skin.nose.length })
    table.insert(slider, { ['label'] = "Bone Twist", ['options'] = nbone, ['default'] = currentSetting.skin.nose.bone_twist })
    table.insert(slider, { ['label'] = "Peak Height", ['options'] = npeak, ['default'] = currentSetting.skin.nose.peak_height })
    table.insert(slider, { ['label'] = "Peak Lower", ['options'] = nplower, ['default'] = currentSetting.skin.nose.peak_lowering })
    table.insert(slider, { ['label'] = "Cheek Features"})
    table.insert(slider, { ['label'] = "Width", ['options'] = cwidth, ['default'] = currentSetting.skin.cheek.width })
    table.insert(slider, { ['label'] = "Height", ['options'] = chigh, ['default'] = currentSetting.skin.cheek.high })
    table.insert(slider, { ['label'] = "Bone Width", ['options'] = cbwidth, ['default'] = currentSetting.skin.cheek.bonewidth })
    table.insert(slider, { ['label'] = "Jaw Features"})
    table.insert(slider, { ['label'] = "Width", ['options'] = jwidth, ['default'] = currentSetting.skin.jaw.width })
    table.insert(slider, { ['label'] = "Length", ['options'] = jlength, ['default'] = currentSetting.skin.jaw.length })
    table.insert(slider, { ['label'] = "Chin Features"})
    table.insert(slider, { ['label'] = "Lowering", ['options'] = clowering, ['default'] = currentSetting.skin.chin.lowering })
    table.insert(slider, { ['label'] = "Width", ['options'] = chinlength, ['default'] = currentSetting.skin.chin.width })
    table.insert(slider, { ['label'] = "Length", ['options'] = chinwidth, ['default'] = currentSetting.skin.chin.length })
    table.insert(slider, { ['label'] = "Hole", ['options'] = chole, ['default'] = currentSetting.skin.chin.hole })
    table.insert(slider, { ['label'] = "Neck Features"})
    table.insert(slider, { ['label'] = "Thickness", ['options'] = neck, ['default'] = currentSetting.skin.neck })
    table.insert(slider, { ['label'] = "Complexion"})
    table.insert(slider, { ['label'] = "Opacity", ['options'] = complexionopacity, ['default'] = currentSetting.skin.complexion.opacity * 10 })
    table.insert(slider, { ['label'] = "Style", ['options'] = complexionstyle, ['default'] = currentSetting.skin.complexion.style })
    table.insert(slider, { ['label'] = "Blemishes"})
    table.insert(slider, { ['label'] = "Opacity", ['options'] = blemishesopacity, ['default'] = currentSetting.skin.blemishes.opacity * 10 })
    table.insert(slider, { ['label'] = "Style", ['options'] = blemishesstyle, ['default'] = currentSetting.skin.blemishes.style })
    table.insert(slider, { ['label'] = "Eyebrows"})
    table.insert(slider, { ['label'] = "Height", ['options'] = eye2, ['default'] = currentSetting.skin.eyebrow.high })

    -- Generate the Menu 
    TriggerEvent('pw_interact:generateSkinChangeMenu', "Skin Customization", slider, {['preventClose'] = true, ['autorefresh'] = true, ['camera'] = "skin", ['return'] = { trigger = "pw_base:charCreator:frontMenu", triggertype = "client"}})
end)

RegisterNUICallback("skinSlider", function(data, cb)
    if data.data.component == "resemblence" then
        local val = data.value / 10
        currentSetting.skin.resemblance = val
        updateCharacter()
    end
end)

function setPlayerSpawn(skin)
    currentSetting = skin
    RequestModel(currentSetting.playerModel)
    while not HasModelLoaded(currentSetting.playerModel) do
        Citizen.Wait(1)
    end
    SetPlayerModel(PlayerId(), currentSetting.playerModel)
    SetPedDefaultComponentVariation(PlayerPedId())
    SetEntityAsMissionEntity(PlayerPedId(), true, true)
    SetModelAsNoLongerNeeded(PlayerPedId())
    updateCharacter()
    TriggerEvent('pw:characterOutfitChanged', currentSetting)
    return true
end

exports('setPlayerSkin', function(skin)
    if skin ~= nil then
        currentSetting = skin
        updateCharacter()
        return true
    else
        return false
    end
end)

exports('setPlayerSpawn', function(skin)
    setPlayerSpawn(skin)
end)

RegisterNetEvent('pw_base:charCreator:editPlayerModel')
AddEventHandler('pw_base:charCreator:editPlayerModel', function()
    local slider, models = {}, {}
    if playerSex then
            table.insert(models, { ['label'] = "Freemode Model ("..#skinOptions.models.male.." Avaliable)", ['data'] = { ['component'] = "model", ['option'] =  "mp_m_freemode_01" }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
        for k, v in pairs(skinOptions.models.male) do
            table.insert(models, { ['label'] = "Model #"..(k).." ("..#skinOptions.models.male.." Avaliable)", ['data'] = { ['component'] = "model", ['option'] =  v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
        end
    else
        table.insert(models, { ['label'] = "Freemode Model ("..#skinOptions.models.female.." Avaliable)", ['data'] = { ['component'] = "model", ['option'] =  "mp_f_freemode_01" }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
        for k, v in pairs(skinOptions.models.female) do
            table.insert(models, { ['label'] = "Model #"..(k).." ("..#skinOptions.models.female.." Avaliable)", ['data'] = { ['component'] = "model", ['option'] =  v }, ['trigger'] = "pw_base:charCreator:changeSkin", ['triggertype'] = "client"} )
        end
    end
    table.insert(slider, { ['label'] = "Player Model"})
    table.insert(slider, { ['label'] = "Height", ['options'] = models, ['default'] = currentSetting.playerModel })
    TriggerEvent('pw_interact:generateSkinChangeMenu', "Skin Customization", slider, {['autorefresh'] = true, ['camera'] = "skin", ['return'] = { trigger = "pw_base:charCreator:frontMenu", triggertype = "client"}})
end)

RegisterNetEvent('pw_base:charCreator:outfitSaved')
AddEventHandler('pw_base:charCreator:outfitSaved', function(data)
    PW.TriggerServerCallback('pw_base:charCreator:saveSkin', function(success)
        if success then
            if not inShop then
                TriggerEvent('pw_instance:leave')
            else
                inShop = false
                exports['pw_clothing']:menuClosed()
                FreezeEntityPosition(PlayerPedId(), false)
                TriggerEvent('pw_clothing:client:processPayment')
                TriggerEvent('pw:characterOutfitChanged', currentSetting)
            end
        end
    end, data.outfitname.data, data.outfitname.value, false)
end)

RegisterNetEvent('pw_base:charCreator:outfitSavedShop')
AddEventHandler('pw_base:charCreator:outfitSavedShop', function(data)
    PW.TriggerServerCallback('pw_base:charCreator:saveSkin', function(success)
        if success then
            inShop = false
            exports['pw_clothing']:menuClosed()
            FreezeEntityPosition(PlayerPedId(), false)
            TriggerEvent('pw_clothing:client:processPayment')
            TriggerEvent('pw:characterOutfitChanged', currentSetting)
        end
    end, data.outfitname.data, data.outfitname.value, true)
end)

RegisterNetEvent('pw_base:charCreator:savedWithoutPurchase')
AddEventHandler('pw_base:charCreator:savedWithoutPurchase', function()
    inShop = false
    exports['pw_clothing']:menuClosed()
    TriggerEvent('pw_clothing:client:processPayment')
    TriggerEvent('pw:characterOutfitChanged', currentSetting)
end)

RegisterNetEvent('pw_base:charCreator:saveOutfitQuestion')
AddEventHandler('pw_base:charCreator:saveOutfitQuestion', function()
    local form = {}
    table.insert(form, { ['type'] = "writting", ['value'] = "Do you wish to save this outfit in your wardrobe?", ['align'] = "center" })
    table.insert(form, { ['type'] = "yesno", ['success'] = 'Yes', ['reject'] = 'No' })
    TriggerEvent('pw_interact:generateForm', 'pw_base:charCreator:saveCharacter', 'client', form, 'Save Outfit?', {}, false, "350px", { {['trigger'] = 'pw_base:charCreator:savedWithoutPurchase', ['method'] = 'client'} })

end)

RegisterNetEvent('pw_base:charCreator:saveCharacter')
AddEventHandler('pw_base:charCreator:saveCharacter', function()
    local form = {  
        { ['type'] = "writting", ['align'] = 'left', ['value'] = "On PixelWorld we save outfits to people's Wardrobes, by default everyone starts of with a Motel with a built in wardrobe"},
        { ['type'] = "text", ['label'] = "Outfit Name", ['name'] = "outfitname", ['data'] = currentSetting },
    }   
    TriggerEvent('pw_interact:generateForm', (inShop and "pw_base:charCreator:outfitSavedShop" or "pw_base:charCreator:outfitSaved"), 'client', form, "Save Character", {}, false, "350px", { {['trigger'] = (inShop and "pw_base:charCreator:frontMenuShop" or "pw_base:charCreator:frontMenu"), ['method'] = "client"} })
end)

function openingMenu(shop, prevSetting)
    inShop = shop
    local playerPed = GetPlayerPed(-1)
    if not inShop then
        FreezeEntityPosition(playerPed, false)
        TaskLookAtCoord(playerPed, 409.5, -998.54, -98.99-0.10, -1, 0, 2)
        TaskStandStill(playerPed, -1)
        SetCamActive(cameras.accessories, true)
    end
    local menu = {}
    --table.insert(menu, { ['label'] = "Change Player Model", ['action'] = "pw_base:charCreator:editPlayerModel", ['triggertype'] = "client", ['color'] = "info" })
    if(currentSetting.playerModel == "mp_m_freemode_01" or currentSetting.playerModel == "mp_f_freemode_01") then
        if not inShop then
            table.insert(menu, { ['label'] = "Skin Customization", ['action'] = "pw_base:charCreator:openSkinMenu", ['triggertype'] = "client", ['color'] = "primary" })
            table.insert(menu, { ['label'] = "Facial Features", ['action'] = "pw_base:charCreator:openFacialFeatures", ['triggertype'] = "client", ['color'] = "info" })
        end
        table.insert(menu, { ['label'] = "Clothing Options", ['action'] = "pw_base:charCreator:openClothingMenu", ['triggertype'] = "client", ['color'] = "primary" })
        table.insert(menu, { ['label'] = "Accessories", ['action'] = "pw_base:charCreator:openAccessoriesMenu", ['triggertype'] = "client", ['color'] = "info" })
    end
        table.insert(menu, { ['label'] = (inShop and "Save Clothing" or "Save Character"), ['action'] = (inShop and "pw_base:charCreator:saveOutfitQuestion" or "pw_base:charCreator:saveCharacter"), ['triggertype'] = "client", ['color'] = "success" })
        if inShop then
            table.insert(menu, { ['label'] = "Cancel", ['action'] = "pw_base:charCreator:cancelChange", ['triggertype'] = "client", ['color'] = "danger" })
        end
    TriggerEvent('pw_interact:generateMenu', menu, (inShop and "Clothing Store" or "Welcome to PixelWorld"), {}, false, {['preventClose'] = true})
end

RegisterNetEvent('pw_base:charCreator:cancelChange')
AddEventHandler('pw_base:charCreator:cancelChange', function()
    PW.TriggerServerCallback('pw_base:server:loadCharacterSkin', function(skin)
        if skin ~= nil then
            exports['pw_clothing']:menuClosed()
            continueSpawn = setPlayerSpawn(skin)
        end
    end)
end)

RegisterNetEvent('pw_base:charCreator:frontMenuShop')
AddEventHandler('pw_base:charCreator:frontMenuShop', function(data)
    openingMenu(true, data)
end)

RegisterNetEvent('pw_base:charCreator:frontMenu')
AddEventHandler('pw_base:charCreator:frontMenu', function()
    openingMenu(false)
end)

function loadSkin(params)
    if params ~= nil then
        currentSetting = params
        updateCharacter()
    end
end

function loadUniform(params)
    if params ~= nil and type(params) == "table" then
        if params.tshirt ~= nil and params.tshirt.one and params.tshirt.one ~= currentSetting.clothing.tshirt.one then
            currentSetting.clothing.tshirt.one = params.tshirt.one
        end
        if params.tshirt ~= nil and params.tshirt.two and params.tshirt.two ~= currentSetting.clothing.tshirt.two then
            currentSetting.clothing.tshirt.two = params.tshirt.two
        end
        if params.arms ~= nil and params.arms.one and params.arms.one ~= currentSetting.clothing.arms.one then
            currentSetting.clothing.arms.one = params.arms.one
        end
        if params.arms ~= nil and params.arms.two and params.arms.two ~= currentSetting.clothing.arms.two then
            currentSetting.clothing.arms.two = params.arms.two
        end
        if params.torso ~= nil and params.torso.one and params.torso.one ~= currentSetting.clothing.torso.one then
            currentSetting.clothing.torso.one = params.torso.one
        end
        if params.torso ~= nil and params.torso.two and params.torso.two ~= currentSetting.clothing.torso.two then
            currentSetting.clothing.torso.two = params.torso.two
        end
        if params.pants ~= nil and params.pants.one and params.pants.one ~= currentSetting.clothing.pants.one then
            currentSetting.clothing.pants.one = params.pants.one
        end
        if params.pants ~= nil and params.pants.two and params.pants.two ~= currentSetting.clothing.pants.two then
            currentSetting.clothing.pants.two = params.pants.two
        end
        if params.shoes ~= nil and params.shoes.one and params.shoes.one ~= currentSetting.clothing.shoes.one then
            currentSetting.clothing.shoes.one = params.shoes.one
        end
        if params.shows ~= nil and params.shows.two and params.shows.two ~= currentSetting.clothing.shoes.two then
            currentSetting.clothing.shoes.two = params.shows.two
        end
        updateCharacter()
    end
end

function updateProps(params)
    if params ~= nil and type(params) == "table" then
        if params.bags ~= nil and params.bags.one ~= nil and params.bags.one ~= currentSetting.accessories.bags.one then
            currentSetting.accessories.bags.one = params.bags.one
        end
        if params.bags ~= nil and params.bags.two ~= nil and params.bags.two ~= currentSetting.accessories.bags.two then
            currentSetting.accessories.bags.two = params.bags.two
        end
        if params.bracelets ~= nil and params.bracelets.one ~= nil and params.bracelets.one ~= currentSetting.accessories.bracelets.one then
            currentSetting.accessories.bracelets.one = params.bracelets.one
        end
        if params.bracelets ~= nil and params.bracelets.two ~= nil and params.bracelets.two ~= currentSetting.accessories.bracelets.two then
            currentSetting.accessories.bracelets.two = params.bracelets.two
        end
        if params.watches ~= nil and params.watches.one ~= nil and params.watches.one ~= currentSetting.accessories.watches.one then
            currentSetting.accessories.watches.one = params.watches.one
        end
        if params.watches ~= nil and params.watches.two ~= nil and params.watches.two ~= currentSetting.accessories.watches.two then
            currentSetting.accessories.watches.two = params.watches.two
        end
        if params.glasses ~= nil and params.glasses.one ~= nil and params.glasses.one ~= currentSetting.accessories.glasses.one then
            currentSetting.accessories.glasses.one = params.glasses.one
        end
        if params.glasses ~= nil and params.glasses.two ~= nil and params.glasses.two ~= currentSetting.accessories.glasses.two then
            currentSetting.accessories.glasses.two = params.glasses.two
        end
        if params.helmet ~= nil and params.helmet.one ~= nil and params.helmet.one ~= currentSetting.accessories.helmet.one then
            currentSetting.accessories.helmet.one = params.helmet.one
        end
        if params.helmet ~= nil and params.helmet.two ~= nil and params.helmet.two ~= currentSetting.accessories.helmet.two then
            currentSetting.accessories.helmet.two = params.helmet.two
        end
        if params.ears ~= nil and params.ears.one ~= nil and params.ears.one ~= currentSetting.accessories.ears.one then
            currentSetting.accessories.ears.one = params.ears.one
        end
        if params.ears ~= nil and params.ears.two ~= nil and params.ears.two ~= currentSetting.accessories.ears.two then
            currentSetting.accessories.ears.two = params.ears.two
        end
        if params.bproof ~= nil and params.bproof.one ~= nil and params.bproof.one ~= currentSetting.accessories.bproof.one then
            currentSetting.accessories.bproof.one = params.bproof.one
        end
        if params.bproof ~= nil and params.bproof.two ~= nil and params.bproof.two ~= currentSetting.accessories.bproof.two then
            currentSetting.accessories.bproof.two = params.bproof.two
        end
        if params.mask ~= nil and params.mask.one ~= nil and params.mask.one ~= currentSetting.accessories.mask.one then
            currentSetting.accessories.mask.one = params.mask.one
        end
        if params.mask ~= nil and params.mask.two ~= nil and params.mask.two ~= currentSetting.accessories.mask.two then
            currentSetting.accessories.mask.two = params.mask.two
        end
        if params.decals ~= nil and params.decals.one ~= nil and params.decals.one ~= currentSetting.accessories.decals.one then
            currentSetting.accessories.decals.one = params.decals.one
        end
        if params.decals ~= nil and params.decals.two ~= nil and params.decals.two ~= currentSetting.accessories.decals.two then
            currentSetting.accessories.decals.two = params.decals.two
        end
        if params.chain ~= nil and params.chain.one ~= nil and params.chain.one ~= currentSetting.accessories.chain.one then
            currentSetting.accessories.chain.one = params.chain.one
        end
        if params.chain ~= nil and params.chain.two ~= nil and params.chain.two ~= currentSetting.accessories.chain.two then
            currentSetting.accessories.chain.two = params.chain.two
        end
        updateCharacter()
    end        
end

exports('updateProps', function(params)
    updateProps(params)
end)

exports('loadUniform', function(params)
    loadUniform(params)
end)

RegisterNetEvent('pw_base:charCreator:setSkin')
AddEventHandler('pw_base:charCreator:setSkin', function(data)
    PW.TablePrint(data)
    loadSkin(data)
end)

exports('loadSkin', function(params)
    loadSkin(params)
end)

function updateCharacter()
    Citizen.CreateThread(function()
        Citizen.Wait(1)
        local playerPed =           GetPlayerPed(-1)
        if(currentSetting.playerModel == "mp_m_freemode_01" or currentSetting.playerModel == "mp_f_freemode_01") then
		    SetPedHeadBlendData         (playerPed,         currentSetting.skin.mom, currentSetting.skin.dad, 0, currentSetting.skin.mom, currentSetting.skin.dad, 0, currentSetting.skin.resemblance, currentSetting.skin.skinmix, 0, false)
            SetPedComponentVariation    (playerPed, 2,      currentSetting.facial.hair.style, 1.0, 1.0)-- Facial
		    SetPedHairColor             (playerPed,         currentSetting.facial.hair.color1, currentSetting.facial.hair.color2)-- Facial
		    SetPedHeadOverlay           (playerPed, 1,      currentSetting.facial.beard.style, currentSetting.facial.beard.opacity)-- Facial
		    SetPedHeadOverlayColor      (playerPed, 1, 1,   currentSetting.facial.beard.color1, currentSetting.facial.beard.color2)-- Facial
		    SetPedHeadOverlay           (playerPed, 2,      currentSetting.facial.eyebrow.style, currentSetting.facial.eyebrow.opacity)-- Facial
		    SetPedHeadOverlayColor      (playerPed, 2, 1,   currentSetting.facial.eyebrow.color1, currentSetting.facial.eyebrow.color2) -- Facial
            SetPedHeadOverlay           (playerPed, 3,      currentSetting.skin.age.style, currentSetting.skin.age.opacity)  -- Skin
            SetPedEyeColor              (playerPed,         currentSetting.skin.eye)  -- Skin
		    SetPedHeadOverlay           (playerPed, 0,      currentSetting.skin.blemishes.style, currentSetting.skin.blemishes.opacity) -- skin
            SetPedHeadOverlay           (playerPed, 6,      currentSetting.skin.complexion.style, currentSetting.skin.complexion.opacity) -- skin
            SetPedFaceFeature           (playerPed, 0,      currentSetting.skin.nose.width) -- Skin
            SetPedFaceFeature           (playerPed, 1,      currentSetting.skin.nose.peak_height) -- Skin
            SetPedFaceFeature           (playerPed, 2,      currentSetting.skin.nose.length) -- Skin
            SetPedFaceFeature           (playerPed, 3,      currentSetting.skin.nose.peak_heigh) -- Skin
            SetPedFaceFeature           (playerPed, 4,      currentSetting.skin.nose.peak_lowering) -- Skin
            SetPedFaceFeature           (playerPed, 5,      currentSetting.skin.nose.bone_twist) -- Skin
            SetPedFaceFeature           (playerPed, 6,      currentSetting.skin.eyebrow.high) -- Skin
            SetPedFaceFeature           (playerPed, 7,      currentSetting.skin.eyebrow.forward) -- Skin
            SetPedFaceFeature           (playerPed, 8,      currentSetting.skin.cheek.high) -- Skin
            SetPedFaceFeature           (playerPed, 9,      currentSetting.skin.cheek.bonewidth) -- Skin
            SetPedFaceFeature           (playerPed, 10,     currentSetting.skin.cheek.width) -- Skin
            SetPedFaceFeature           (playerPed, 11,     currentSetting.skin.eye) -- Skin
            SetPedFaceFeature           (playerPed, 13,     currentSetting.skin.jaw.width) -- Skin
            SetPedFaceFeature           (playerPed, 14,     currentSetting.skin.jaw.length) -- Skin
            SetPedFaceFeature           (playerPed, 15,     currentSetting.skin.chin.lowering) -- Skin
            SetPedFaceFeature           (playerPed, 16,     currentSetting.skin.chin.width) -- Skin
            SetPedFaceFeature           (playerPed, 17,     currentSetting.skin.chin.length) -- Skin
            SetPedFaceFeature           (playerPed, 18,     currentSetting.skin.chin.hole) -- Skin
            SetPedFaceFeature           (playerPed, 19,     currentSetting.skin.neck) -- Skin
            SetPedHeadOverlay           (playerPed, 8,      currentSetting.facial.lipstick.style, currentSetting.facial.lipstick.opacity)-- Facial
            SetPedHeadOverlayColor      (playerPed, 8, 1,   currentSetting.facial.lipstick.color1, currentSetting.facial.lipstick.color2)	-- Facial
            SetPedHeadOverlay           (playerPed, 4,      currentSetting.facial.makeup.style, currentSetting.facial.makeup.opacity)-- Facial
            SetPedHeadOverlayColor      (playerPed, 4, 1,   currentSetting.facial.makeup.color1,      currentSetting.facial.makeup.color2)-- Facial
            SetPedFaceFeature           (playerPed, 12,     currentSetting.skin.lips.lipstickness) -- Facial
            SetPedComponentVariation	(playerPed, 10,	    currentSetting.accessories.decals.one, currentSetting.accessories.decals.two, 2)		-- decals
            SetPedComponentVariation	(playerPed, 1,	    currentSetting.accessories.mask.one, currentSetting.accessories.mask.two, 2)			-- mask
            SetPedComponentVariation	(playerPed, 9,	    currentSetting.accessories.bproof.one, currentSetting.accessories.bproof.two, 2)		-- bulletproof
            SetPedComponentVariation	(playerPed, 7,	    currentSetting.accessories.chain.one, currentSetting.accessories.chain.two, 2)			-- chain
            SetPedComponentVariation	(playerPed, 5,	    currentSetting.accessories.bags.one, currentSetting.accessories.bags.two, 2)			-- Bag
  
            if currentSetting.accessories.helmet.one == -1 then
                ClearPedProp(playerPed, 0)
            else
                SetPedPropIndex(playerPed, 0, currentSetting.accessories.helmet.one, currentSetting.accessories.helmet.two, 2)	            -- Helmet
            end
        
            if currentSetting.accessories.watches.one == -1 then
                ClearPedProp(playerPed, 6)
            else
                SetPedPropIndex(playerPed, 6, currentSetting.accessories.watches.one, currentSetting.accessories.watches.two, 2)              -- Watches
            end
        
            if currentSetting.accessories.bracelets.one == -1 then
                ClearPedProp(playerPed,	7)
            else
                SetPedPropIndex(playerPed, 7, currentSetting.accessories.bracelets.one, currentSetting.accessories.bracelets.two, 2)	    -- Bracelets
            end           

            if currentSetting.accessories.ears.one == -1 then
                ClearPedProp(playerPed, 2)
            else
                SetPedPropIndex(playerPed, 2, currentSetting.accessories.ears.one, currentSetting.accessories.ears.two, 2)				    		-- Ears Accessories
            end

            if currentSetting.accessories.glasses.one == -1 then
                ClearPedProp(playerPed, 1)
            else
                SetPedPropIndex(playerPed, 1, currentSetting.accessories.glasses.one,currentSetting.accessories.glasses.two, 2)				-- Glasses
            end
            SetPedComponentVariation	(playerPed, 11,	    currentSetting.clothing.torso.one,	currentSetting.clothing.torso.two, 2)				-- torso parts
            SetPedComponentVariation	(playerPed, 8,	    currentSetting.clothing.tshirt.one, currentSetting.clothing.tshirt.two, 2)				-- Tshirt            
            SetPedComponentVariation	(playerPed, 3,	    currentSetting.clothing.arms.one,	currentSetting.clothing.arms.two, 2)				-- Amrs
            SetPedComponentVariation	(playerPed, 4,	    currentSetting.clothing.pants.one,	currentSetting.clothing.pants.two, 2)				-- pants
            SetPedComponentVariation	(playerPed, 6,	    currentSetting.clothing.shoes.one,	currentSetting.clothing.shoes.two, 2)				-- shoes
        end
        return
    end)
end