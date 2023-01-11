//
//  Filial.swift
//  task4
//
//  Created by Misha Volkov on 9.01.23.
//

import Foundation

typealias FilialResponse = [Filial]

struct Filial: Codable, ElementResponse {
    let filialId: String
    let sapId: String
    let filialName: String
    let nameType: String
    let name: String
    let streetType: String
    let street: String
    let homeNumber: String
    let nameTypePrev: String?
    let namePrev: String?
    let streetTypePrev: String
    let streetPrev: String
    let homeNumberPrev: String
    let infoText: String
    let infoWorktime: String
    let infoBankBik: String?
    let infoBankUnp: String?
    let latitude: String
    let longitude: String
    let belNumberSchet: String
    let foreignNumberSchet: String
    let phoneInfo: String
    let infoWeekend1Day, infoWeekend2Day, infoWeekend3Day, infoWeekend4Day,
        infoWeekend5Day, infoWeekend6Day, infoWeekend7Day: String
    let infoWeekend1Time, infoWeekend2Time, infoWeekend3Time, infoWeekend4Time,
        infoWeekend5Time, infoWeekend6Time, infoWeekend7Time: String
    let dopNum: String
    // TODO: type uslugi? uslPriemZayvleniyObsluzhivanieDerzhatelej - 41
    let uslBroker, uslBuySlitki, uslCardInternet, uslCennieBumagi, uslCheckDoverVnebanka, uslChekiGilie,
        uslChekiImuschestvo, uslClubBarhat, uslClubKartblansh, uslClubLedi, uslClubNastart, uslClubPersona,
        uslClubSchodry, uslClubSvoi, uslClubZclass, uslCoinsExchange, uslDepositariy, uslDepDoverennosti,
        uslDepScheta, uslDepViplati, uslDocObligacBelarusbank, uslDoverUpr, uslDoverUprGos, uslDragMetal,
        uslIbank, uslInkassoPriem, uslInkassoPriemDenegBel, uslIntCards, uslIzbizSchetaOperacii,
        uslIzbizSchetaOtkr, uslKamniBrill, uslKonversiyaForeignVal, uslLoterei, uslMoRb,
        uslOperationsBezdokumentarObligacii, uslOperationsSberSertif, uslOperPoSchOtkrVRup,
        uslPerechisleniePoRekvizitamKartochki, uslPerechislenieSoSchetaBezKart, uslPlategi,
        uslPodlinnostBanknot, uslPogashenieDocumentarObligacii, uslPopolnenieSchetaBezKart,
        uslPopolnenieSchetaBynIspKarts, uslPopolnenieSchetaUsdIspKarts, uslPov, uslPriemDocPokupkaObl,
        uslPriemCennosteiNaHranenie, uslPriemCennostejNaHranenie, uslPriemDocsFlDepozitOperations,
        uslPriemDocsVidachaSoprLgotIpotech, uslPriemDocNaKreditsOverdrafts, uslPriemDocNaLizing,
        uslPriemInkasso, uslPriemOblMf, uslPriemPlatejeiBynIp, uslPriemPlatejeiEurIp,
        uslPriemVznosovInostrValOtStraxAgentov, uslPriemZayvleniyObsluzhivanieDerzhatelej, uslProdagaMonet,
        uslRazmenForeignVal, uslRazmProdazhaDocumentarObligacii, uslRbCard, uslRegistrationValDogovor,
        uslReturnBynIspKarts, uslReturnUsdIspKarts, uslRko, uslSeif, uslSoprovKreditVTomChisleMagnit,
        uslStrahovanieAvto, uslStrahovanieAvtoPogran, uslStrahovanieDetei, uslStrahovanieDohodPodZaschitoy,
        uslStrahovanieExpress, uslStrahovanieFinansPodZaschitoy, uslStrahovanieGreenKarta,
        uslStrahovanieHome, uslStrahovanieKartochki, uslStrahovanieKasko, uslStrahovanieKomplex,
        uslStrahovanieMedicineNerezident, uslStrahovaniePerevozki, uslStrahovanieSZabotoiOBlizkih,
        uslStrahovanieTimeAbroad, uslStrahovanieZashhitaOtKleshha, uslStrahovkaSite, uslStroysber,
        uslStroysberNew, uslSubsidiyaScheta, uslSwift, uslVidachSpravokPoKreditOverdr,
        uslViplataVozmPoIncasso, uslVklad, uslVozvratNds, uslVydachaNalVBanke, uslVydachaVypiski,
        uslVypllataBelRub, uslVzk, uslPlategiAll, uslPlategiInForeignVal, uslPlategiZaProezdVPolzuBanka,
        uslPlategiMinusMobi, uslPlategiMinusInternet, uslPlategiMinusMobiInternetFull,
        uslPlategiNalMinusKromeKredit: String?
    let filialNum: String
    let cbuNum: String
    let otdNum: String

    var id: String { return filialId }
    var installPlace: String { return streetType + " " + street + ", " + homeNumber }
    var workTime: String { return infoWorktime }
    var currency: String { return "" }
    var cashIn: String { return "" }
    var elementType: BankElements { return .filial }

    enum CodingKeys: String, CodingKey {
        case filialId = "filial_id"
        case sapId = "sap_id"
        case filialName = "filial_name"
        case nameType = "name_type"
        case name
        case streetType = "street_type"
        case street = "street"
        case homeNumber = "home_number"
        case nameTypePrev = "name_type_prev"
        case namePrev = "name_prev"
        case streetTypePrev = "street_type_prev"
        case streetPrev = "street_prev"
        case homeNumberPrev = "home_number_prev"
        case infoText = "info_text"
        case infoWorktime = "info_worktime"
        case infoBankBik = "info_bank_bik"
        case infoBankUnp = "info_bank_unp"
        case latitude = "GPS_X"
        case longitude = "GPS_Y"
        case belNumberSchet = "bel_number_schet"
        case foreignNumberSchet = "foreign_number_schet"
        case phoneInfo = "phone_info"
        case infoWeekend1Day = "info_weekend1_day"
        case infoWeekend2Day = "info_weekend2_day"
        case infoWeekend3Day = "info_weekend3_day"
        case infoWeekend4Day = "info_weekend4_day"
        case infoWeekend5Day = "info_weekend5_day"
        case infoWeekend6Day = "info_weekend6_day"
        case infoWeekend7Day = "info_weekend7_day"
        case infoWeekend1Time = "info_weekend1_time"
        case infoWeekend2Time = "info_weekend2_time"
        case infoWeekend3Time = "info_weekend3_time"
        case infoWeekend4Time = "info_weekend4_time"
        case infoWeekend5Time = "info_weekend5_time"
        case infoWeekend6Time = "info_weekend6_time"
        case infoWeekend7Time = "info_weekend7_time"
        case dopNum = "dop_num"
        case uslBroker = "usl_broker"
        case uslBuySlitki = "usl_buy_slitki"
        case uslCardInternet = "usl_card_internet"
        case uslCennieBumagi = "usl_cennie_bumagi"
        case uslCheckDoverVnebanka = "usl_check_dover_vnebanka"
        case uslChekiGilie = "usl_cheki_gilie"
        case uslChekiImuschestvo = "usl_cheki_imuschestvo"
        case uslClubBarhat = "usl_club_barhat"
        case uslClubKartblansh = "usl_club_kartblansh"
        case uslClubLedi = "usl_club_ledi"
        case uslClubNastart = "usl_club_nastart"
        case uslClubPersona = "usl_club_persona"
        case uslClubSchodry = "usl_club_schodry"
        case uslClubSvoi = "usl_club_svoi"
        case uslClubZclass = "usl_club_zclass"
        case uslCoinsExchange = "usl_coins_exchange"
        case uslDepositariy = "usl_depositariy"
        case uslDepDoverennosti = "usl_dep_doverennosti"
        case uslDepScheta = "usl_dep_scheta"
        case uslDepViplati = "usl_dep_viplati"
        case uslDocObligacBelarusbank = "usl_docObligac_belarusbank"
        case uslDoverUpr = "usl_dover_upr"
        case uslDoverUprGos = "usl_dover_upr_gos"
        case uslDragMetal = "usl_drag_metal"
        case uslIbank = "usl_ibank"
        case uslInkassoPriem = "usl_inkasso_priem"
        case uslInkassoPriemDenegBel = "usl_inkasso_priem_deneg_bel"
        case uslIntCards = "usl_int_cards"
        case uslIzbizSchetaOperacii = "usl_izbiz_scheta_operacii"
        case uslIzbizSchetaOtkr = "usl_izbiz_scheta_otkr"
        case uslKamniBrill = "usl_kamni_brill"
        case uslKonversiyaForeignVal = "usl_konversiya_foreign_val"
        case uslLoterei = "usl_loterei"
        case uslMoRb = "usl_mo_rb"
        case uslOperationsBezdokumentarObligacii = "usl_operations_bezdokumentar_obligacii"
        case uslOperationsSberSertif = "usl_operations_sber_sertif"
        case uslOperPoSchOtkrVRup = "usl_oper_po_sch_otkr_v_rup"
        case uslPerechisleniePoRekvizitamKartochki = "usl_perechislenie_po_rekvizitam_kartochki"
        case uslPerechislenieSoSchetaBezKart = "usl_perechislenie_so_scheta_bez_kart"
        case uslPlategi = "usl_plategi"
        case uslPodlinnostBanknot = "usl_podlinnost_banknot"
        case uslPogashenieDocumentarObligacii = "usl_pogashenie_documentar_obligacii"
        case uslPopolnenieSchetaBezKart = "usl_popolnenieSchetaBezKart"
        case uslPopolnenieSchetaBynIspKarts = "usl_popolnenieSchetaBynIspKarts"
        case uslPopolnenieSchetaUsdIspKarts = "usl_popolnenieSchetaUsdIspKarts"
        case uslPov = "usl_pov"
        case uslPriemDocPokupkaObl = "usl_priemDocPokupkaObl"
        case uslPriemCennosteiNaHranenie = "usl_priem_cennostei_na_hranenie"
        case uslPriemCennostejNaHranenie = "usl_priem_cennostej_na_hranenie"
        case uslPriemDocsFlDepozitOperations = "usl_priem_docs_fl_depozit_operations"
        case uslPriemDocsVidachaSoprLgotIpotech = "usl_priem_docs_vidacha_sopr_lgot_ipotech"
        case uslPriemDocNaKreditsOverdrafts = "usl_priem_doc_na_kredits_overdrafts"
        case uslPriemDocNaLizing = "usl_priem_doc_na_lizing"
        case uslPriemInkasso = "usl_priem_inkasso"
        case uslPriemOblMf = "usl_priem_obl_mf"
        case uslPriemPlatejeiBynIp = "usl_priem_platejei_byn_ip"
        case uslPriemPlatejeiEurIp = "usl_priem_platejei_eur_ip"
        case uslPriemVznosovInostrValOtStraxAgentov = "usl_priem_vznosov_inostr_val_ot_strax_agentov"
        case uslPriemZayvleniyObsluzhivanieDerzhatelej = "usl_priem_zayvleniy_obsluzhivanie_derzhatelej"
        case uslProdagaMonet = "usl_prodaga_monet"
        case uslRazmenForeignVal = "usl_razmen_foreign_val"
        case uslRazmProdazhaDocumentarObligacii = "usl_razm_prodazha_documentar_obligacii"
        case uslRbCard = "usl_rb_card"
        case uslRegistrationValDogovor = "usl_registration_val_dogovor"
        case uslReturnBynIspKarts = "usl_return_BynIspKarts"
        case uslReturnUsdIspKarts = "usl_return_UsdIspKarts"
        case uslRko = "usl_rko"
        case uslSeif = "usl_seif"
        case uslSoprovKreditVTomChisleMagnit = "usl_soprov_kredit_v_tom_chisle_magnit"
        case uslStrahovanieAvto = "usl_strahovanie_avto"
        case uslStrahovanieAvtoPogran = "usl_strahovanie_avto_pogran"
        case uslStrahovanieDetei = "usl_strahovanie_detei"
        case uslStrahovanieDohodPodZaschitoy = "usl_strahovanie_dohod_pod_zaschitoy"
        case uslStrahovanieExpress = "usl_strahovanie_express"
        case uslStrahovanieFinansPodZaschitoy = "usl_strahovanie_finans_pod_zaschitoy"
        case uslStrahovanieGreenKarta = "usl_strahovanie_green_karta"
        case uslStrahovanieHome = "usl_strahovanie_home"
        case uslStrahovanieKartochki = "usl_strahovanie_kartochki"
        case uslStrahovanieKasko = "usl_strahovanie_kasko"
        case uslStrahovanieKomplex = "usl_strahovanie_komplex"
        case uslStrahovanieMedicineNerezident = "usl_strahovanie_medicine_nerezident"
        case uslStrahovaniePerevozki = "usl_strahovanie_perevozki"
        case uslStrahovanieSZabotoiOBlizkih = "usl_strahovanie_s_zabotoi_o_blizkih"
        case uslStrahovanieTimeAbroad = "usl_strahovanie_timeAbroad"
        case uslStrahovanieZashhitaOtKleshha = "usl_strahovanie_zashhita_ot_kleshha"
        case uslStrahovkaSite = "usl_strahovka_site"
        case uslStroysber = "usl_stroysber"
        case uslStroysberNew = "usl_stroysber_new"
        case uslSubsidiyaScheta = "usl_subsidiya_scheta"
        case uslSwift = "usl_swift"
        case uslVidachSpravokPoKreditOverdr = "usl_vidach_spravok_po_kredit_overdr"
        case uslViplataVozmPoIncasso = "usl_viplata_vozm_po_incasso"
        case uslVklad = "usl_vklad"
        case uslVozvratNds = "usl_vozvrat_nds"
        case uslVydachaNalVBanke = "usl_vydacha_nal_v_banke"
        case uslVydachaVypiski = "usl_vydacha_vypiski"
        case uslVypllataBelRub = "usl_vypllata_bel_rub"
        case uslVzk = "usl_vzk"
        case uslPlategiAll = "usl_plategi_all"
        case uslPlategiInForeignVal = "usl_plategi_in_foreign_val"
        case uslPlategiZaProezdVPolzuBanka = "usl_plategi_za_proezd_v_polzu_banka"
        case uslPlategiMinusMobi = "usl_plategi_minus_mobi"
        case uslPlategiMinusInternet = "usl_plategi_minus_internet"
        case uslPlategiMinusMobiInternetFull = "usl_plategi_minus_mobi_internet_full"
        case uslPlategiNalMinusKromeKredit = "usl_plategi_nal_minus_krome_kredit"
        case filialNum = "filial_num"
        case cbuNum = "cbu_num"
        case otdNum = "otd_num"
    }

    init(data: Data) throws {
        self = try JSONDecoder().decode(Filial.self, from: data)
    }
}

extension Array where Element == FilialResponse.Element {
    init(data: Data) throws {
        self = try JSONDecoder().decode(FilialResponse.self, from: data)
    }
}
