CLASS ycl_bw_pc_tool_app DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app .

    TYPES: BEGIN OF t_s_joblist,
             jobname    TYPE btcjob,
             jobcount   TYPE btcjobcnt,
             sdlstrtdt  TYPE btcsdate,
             sdlstrttm  TYPE btcstime,
             job_status TYPE btcstatus,
             eventid    TYPE btceventid,
             eventparm  TYPE btcevtparm,
             chain_id   TYPE rspc_chain,
             prdmins    TYPE btcpmin,
             prdhours   TYPE btcphour,
             prddays    TYPE btcpday,
             prdweeks   TYPE btcpweek,
             prdmonths  TYPE btcpmnth,
             periodic   TYPE btcpflag,
           END OF t_s_joblist.
    TYPES t_t_joblist TYPE STANDARD TABLE OF t_s_joblist WITH EMPTY KEY.
    DATA: joblist TYPE STANDARD TABLE OF t_s_joblist WITH EMPTY KEY.

    TYPES: BEGIN OF t_s_pclist,
             chain_id    TYPE rspc_chain,
             chain_descr TYPE rstxtlg,
             log_id      TYPE rspc_logid,
             run_date    TYPE sydatum,
             run_time    TYPE syuzeit,
             run_status  TYPE rspc_state,
             main        TYPE abap_bool,
             selected    TYPE abap_bool,
           END OF t_s_pclist.
    TYPES t_t_pclist TYPE STANDARD TABLE OF t_s_pclist WITH EMPTY KEY.
    DATA pclist TYPE STANDARD TABLE OF t_s_pclist WITH EMPTY KEY.

    TYPES: BEGIN OF t_s_ui_model,
             selected            TYPE abap_bool,
             chain_id            TYPE rspc_chain,
             chain_descr         TYPE rstxtlg,
             log_id              TYPE rspc_logid,
             run_date            TYPE sydatum,
             run_time            TYPE syuzeit,
             run_status          TYPE rspc_state,
             main                TYPE abap_bool,
             run_status_icon     TYPE string,
             run_status_text     TYPE string,
             run_status_state    TYPE string,
             jobname             TYPE btcjob,
             jobcount            TYPE btcjobcnt,
             sdlstrtdt           TYPE sydatum,
             sdlstrttm           TYPE syuzeit,
             startcond_sdlstrtdt TYPE sydatum,
             startcond_sdlstrttm TYPE syuzeit,
             job_status          TYPE btcstatus,
             job_status_icon     TYPE string,
             job_status_text     TYPE string,
             job_status_state    TYPE string,
             sched_status        TYPE btcstatus,
             sched_status_icon   TYPE string,
             sched_status_text   TYPE string,
             sched_status_state  TYPE string,
             eventid             TYPE btceventid,
             eventparm           TYPE btcevtparm,
             is_in_include       TYPE abap_bool,
             is_std_pc           TYPE abap_bool,
             prdmins             TYPE btcpmin,
             prdhours            TYPE btcphour,
             prddays             TYPE btcpday,
             prdweeks            TYPE btcpweek,
             prdmonths           TYPE btcpmnth,
             periodic            TYPE btcpflag,
             frequency_tx        TYPE string,
           END OF t_s_ui_model.
    TYPES t_t_ui_model TYPE STANDARD TABLE OF t_s_ui_model WITH EMPTY KEY.

    DATA ui_model TYPE STANDARD TABLE OF t_s_ui_model WITH EMPTY KEY.
    DATA model TYPE STANDARD TABLE OF t_s_ui_model WITH EMPTY KEY.

    DATA pc_include TYPE uname.             "List of PC from INCLUDE of RSPCM
    TYPES: BEGIN OF t_s_pc_includes,
             uname TYPE uname,
             descr TYPE string,
             order TYPE i,
           END OF t_s_pc_includes.
    TYPES t_t_pc_includes TYPE STANDARD TABLE OF t_s_pc_includes WITH EMPTY KEY.
    DATA pc_includes TYPE t_t_pc_includes.

    TYPES: BEGIN OF t_s_chain_id_list,
             chain_id   TYPE rspc_chain,
             job_status TYPE btcstatus,
           END OF t_s_chain_id_list.
    TYPES t_t_chain_id_list TYPE STANDARD TABLE OF t_s_chain_id_list WITH EMPTY KEY.


    TYPES: BEGIN OF t_s_next_start,
             sdlstrtdt TYPE tbtco-sdlstrtdt,
             sdlstrttm TYPE tbtco-sdlstrttm,
           END OF t_s_next_start.

    DATA: show_std_pc       TYPE abap_bool,
          show_only_include TYPE abap_bool.

    TYPES:
      BEGIN OF t_s_msg,
        type        TYPE string,
        title       TYPE string,
        subtitle    TYPE string,
        description TYPE string,
        group       TYPE string,
      END OF t_s_msg.
    TYPES: t_t_msg TYPE STANDARD TABLE OF t_s_msg WITH EMPTY KEY.

    DATA: msgs TYPE t_t_msg.

    DATA favicon  TYPE string.
    DATA check_initialized TYPE abap_bool.
    DATA client TYPE REF TO z2ui5_if_client.

    "! <p class="shorttext synchronized" lang="en">App Initialization</p>
    "!
    METHODS on_init.

    "! <p class="shorttext synchronized" lang="en">App events</p>
    "!
    METHODS on_event.

    "! <p class="shorttext synchronized" lang="en">App view</p>
    "!
    METHODS on_view.


  PROTECTED SECTION.

  PRIVATE SECTION.

    METHODS:
      get_job_list RETURNING VALUE(e_t_joblist) TYPE t_t_joblist,

      get_pc_list IMPORTING i_user            TYPE rspc_monitor_include
                            i_refresh         TYPE abap_bool
                  RETURNING VALUE(e_t_pclist) TYPE t_t_pclist,

      update_ui_from_model,

      is_not_standard_include RETURNING VALUE(is_not_standard_include) TYPE abap_bool,

      add_pc_to_include IMPORTING it_chain_id     TYPE t_t_chain_id_list
                                  i_include_name  TYPE rspc_monitor_include
                        RETURNING VALUE(ret_code) TYPE syst_subrc,

      fill_model,

      refresh_model IMPORTING i_user    TYPE rspc_monitor_include
                              i_refresh TYPE abap_bool,

      get_pc_includes RETURNING VALUE(e_t_pc_includes) TYPE t_t_pc_includes,

      get_next_start_date IMPORTING chain_id              TYPE rspc_chain
                          RETURNING VALUE(e_s_next_start) TYPE t_s_next_start,

      unschedule_chain IMPORTING chain_id         TYPE rspc_chain
                       RETURNING VALUE(e_retcode) TYPE syst_subrc,

      schedule_chain IMPORTING chain_id         TYPE rspc_chain
                     RETURNING VALUE(e_retcode) TYPE syst_subrc,

      schedule_unschedule_chains IMPORTING chain_id_list TYPE t_t_chain_id_list
                                           action        TYPE string,

      display_msg_popover IMPORTING id TYPE string,

      add_message IMPORTING i_title   TYPE string
                            i_retcode TYPE syst_subrc.

ENDCLASS.



CLASS ycl_bw_pc_tool_app IMPLEMENTATION.


  METHOD add_pc_to_include.

    DATA: l_rspc_monitor TYPE rspc_monitor.

    LOOP AT it_chain_id INTO DATA(l_chain_id).
      SELECT SINGLE chain_id FROM rspc_monitor INTO @DATA(l_tmp)
        WHERE chain_id = @l_chain_id-chain_id
          AND uname = @i_include_name.
      IF sy-subrc <> 0.
        CLEAR l_rspc_monitor.
        l_rspc_monitor-chain_id = l_chain_id.
        l_rspc_monitor-uname = i_include_name.
        INSERT rspc_monitor FROM l_rspc_monitor.
        DATA(retcode) = sy-subrc.

        add_message( i_title =  |Insert { l_chain_id-chain_id } in { i_include_name }| i_retcode = retcode ).

        IF sy-subrc = 0.
          COMMIT WORK.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD fill_model.

    DATA: l_model TYPE t_s_ui_model.

    DATA: prdmonths(20) TYPE c,
          prdweeks(20)  TYPE c,
          prddays(20)   TYPE c,
          prdhours(20)  TYPE c,
          prdmins(20)   TYPE c.

    REFRESH model.

*   Complete the list of PC with the job information
    LOOP AT pclist INTO DATA(l_pc).

      l_model = CORRESPONDING #( l_pc ).
      IF line_exists( joblist[ chain_id = l_pc-chain_id ] ).
        l_model = CORRESPONDING #( BASE ( l_model ) joblist[ chain_id = l_pc-chain_id ] ).
      ENDIF.
      l_model-is_in_include = abap_true.

      APPEND l_model TO model.

    ENDLOOP.


    CLEAR l_model.

*   Add PC that are scheduled but are not in the PC list
    LOOP AT joblist INTO DATA(job).

      IF NOT line_exists( pclist[ chain_id = job-chain_id ] ).
        l_model = CORRESPONDING #( BASE ( l_model ) job ).
        l_model-is_in_include = abap_false.

        SELECT SINGLE txtlg FROM rspcchaint INTO l_model-chain_descr
          WHERE chain_id = l_model-chain_id
           AND langu = 'E'.

        APPEND l_model TO model.

      ENDIF.
    ENDLOOP.

    LOOP AT model ASSIGNING FIELD-SYMBOL(<model>).

      <model>-run_status_state = SWITCH string( <model>-run_status WHEN 'G' THEN 'Success'
                                                                   WHEN 'R' THEN 'Error'
                                                                   WHEN 'X' THEN 'None'
                                                                   WHEN 'A' THEN 'Warning'
                                                                   ELSE          'None').
      <model>-run_status_text  = SWITCH string( <model>-run_status WHEN 'G' THEN 'Completed'
                                                                   WHEN 'R' THEN 'Error'
                                                                   WHEN 'X' THEN ''
                                                                   WHEN 'A' THEN 'Active'
                                                                   WHEN ''  THEN '').
      <model>-run_status_icon  = SWITCH string( <model>-run_status WHEN 'G' THEN 'sap-icon://sys-enter-2'
                                                                   WHEN 'R' THEN 'sap-icon://error'
                                                                   WHEN 'X' THEN ''
                                                                   WHEN 'A' THEN 'sap-icon://alert'
                                                                   WHEN ''  THEN '').
      <model>-job_status_icon = SWITCH string( <model>-job_status  WHEN '' THEN ''
                                                                   ELSE         'sap-icon://accept' ).
      <model>-job_status_text = SWITCH string( <model>-job_status  WHEN '' THEN ''
                                                                   ELSE         'Scheduled' ).
      <model>-job_status_state = SWITCH string( <model>-job_status WHEN '' THEN 'None'
                                                                   ELSE         'Success' ).

      DATA(l_startcond_next_pc) = get_next_start_date( EXPORTING chain_id = <model>-chain_id ).
      <model>-startcond_sdlstrtdt = l_startcond_next_pc-sdlstrtdt.
      <model>-startcond_sdlstrttm = l_startcond_next_pc-sdlstrttm.

      <model>-sched_status_state = 'None'.
      IF ( <model>-startcond_sdlstrtdt <> <model>-sdlstrtdt OR
           <model>-startcond_sdlstrttm <> <model>-sdlstrttm ) AND
           NOT <model>-sdlstrtdt IS INITIAL.
        <model>-sched_status = 'X'.
        <model>-sched_status_icon = 'sap-icon://alert'.
        <model>-sched_status_text = 'Job schedule and PC start cond. are different'.
        <model>-sched_status_state = 'Warning'.
      ENDIF.

      <model>-is_std_pc = COND #( WHEN <model>-chain_id(1) = '0' THEN abap_true
                                  ELSE                                abap_false ).



      CLEAR: prdmonths, prdweeks, prddays, prdhours, prdmins.
      IF <model>-prdmonths > 0.
        prdmonths = <model>-prdmonths.
        SHIFT prdmonths LEFT DELETING LEADING '0'.
        prdmonths = | { prdmonths } month(s)|.
      ENDIF.
      IF <model>-prdweeks > 0.
        prdweeks = <model>-prdweeks.
        SHIFT prdweeks LEFT DELETING LEADING '0'.
        prdweeks = | { prdweeks } week(s)|.
      ENDIF.
      IF <model>-prdhours > 0.
        prdhours = <model>-prdhours.
        SHIFT prdhours LEFT DELETING LEADING '0'.
        prdhours = | { prdhours } hour(s)|.
      ENDIF.
      IF <model>-prddays > 0.
        prddays = <model>-prddays.
        SHIFT prddays LEFT DELETING LEADING '0'.
        prddays = | { prddays } day(s)|.
      ENDIF.
      IF <model>-prdmins > 0.
        prdmins = <model>-prdmins.
        SHIFT prdmins LEFT DELETING LEADING '0'.
        prdmins = | { prdmins } min(s)|.
      ENDIF.
      IF <model>-prdmonths + <model>-prdweeks + <model>-prddays + <model>-prdhours  + <model>-prdmins > 0.
        <model>-frequency_tx = 'Every' && prdmonths && prdweeks && prddays && prdhours && prdmins.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD is_not_standard_include.

    is_not_standard_include = abap_false.
    IF pc_include(1) <> '#'.
      is_not_standard_include = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD get_job_list.

    TYPES: BEGIN OF t_s_list.
             INCLUDE TYPE tbtco.
             TYPES: progname TYPE btcprog,
             variant  TYPE btcvariant,
             t_params TYPE rsparams_tt,
           END OF t_s_list.
    TYPES  t_t_list TYPE TABLE OF t_s_list.
    DATA: l_t_list  TYPE t_t_list,
          l_joblist TYPE t_s_joblist.

    SELECT * FROM tbtco INTO CORRESPONDING FIELDS OF TABLE l_t_list
        WHERE jobname = 'BI_PROCESS_TRIGGER'
          AND ( status = 'S' OR status = 'Z' ).

    PERFORM filter IN PROGRAM rspc_display_jobs CHANGING l_t_list.

    LOOP AT l_t_list INTO DATA(l_list).

      l_joblist = CORRESPONDING #( l_list MAPPING job_status = status ).

      IF line_exists( l_list-t_params[ selname = 'CHAIN' ] ).
        l_joblist-chain_id = l_list-t_params[ selname = 'CHAIN' ]-low.
      ENDIF.
      IF l_joblist-sdlstrtdt = ''. l_joblist-sdlstrtdt = 0. ENDIF.
      IF l_joblist-sdlstrttm = ''. l_joblist-sdlstrttm = 0. ENDIF.

      IF l_joblist-prdhours > 0.
      ENDIF.

      APPEND l_joblist TO e_t_joblist.

    ENDLOOP.

  ENDMETHOD.


  METHOD on_event.

    CASE client->get( )-event.
      WHEN 'ON_BTN_INCLUDE'.

        DATA(o_pc_chain_list) = NEW t_t_chain_id_list( FOR wa IN ui_model WHERE ( selected = 'X' ) ( chain_id = wa-chain_id ) ).

        DATA(retcode) = add_pc_to_include( EXPORTING it_chain_id = o_pc_chain_list->* i_include_name = pc_include ).

        refresh_model( i_refresh = 'X' i_user = pc_include ).
        client->view_model_update( ).
        client->message_toast_display( 'Action completed. Check the messages.' ).

      WHEN 'ON_CMB_INCLUDE'.

        refresh_model( i_refresh = '' i_user = pc_include ).
        client->view_model_update( ).

      WHEN 'ON_BTN_REFRESH_STATUS'.

        refresh_model( i_refresh = 'X' i_user = pc_include ).
        client->view_model_update( ).

      WHEN 'ON_BTN_SCHEDULE'.

        DATA(o_sched) = NEW t_t_chain_id_list( FOR wa IN ui_model WHERE ( selected = 'X' ) ( chain_id = wa-chain_id job_status = wa-job_status ) ).

        schedule_unschedule_chains( chain_id_list = o_sched->* action = 'SCHEDULE' ).
        refresh_model( i_refresh = 'X' i_user = pc_include ).
        client->view_model_update( ).
        client->message_toast_display( 'Action completed. Check the messages.' ).

      WHEN 'ON_BTN_UNSCHEDULE'.

        DATA(o_unsched) = NEW t_t_chain_id_list( FOR wa IN ui_model WHERE ( selected = 'X' ) ( chain_id = wa-chain_id job_status = wa-job_status ) ).

        schedule_unschedule_chains( chain_id_list = o_unsched->* action = 'UNSCHEDULE' ).
        refresh_model( i_refresh = 'X' i_user = pc_include ).
        client->view_model_update( ).
        client->message_toast_display( 'Action completed. Check the messages.' ).

      WHEN 'ON_CHK_SHOW_STD'.

        refresh_model( i_refresh = 'X' i_user = pc_include ).
        client->view_model_update( ).

      WHEN 'ON_MSG_POPOVER'.

        display_msg_popover( `test` ).

      WHEN 'ON_MSG_POPOVER_CLOSE'.

        client->popover_destroy( ).

    ENDCASE.

  ENDMETHOD.


  METHOD on_init.

    show_std_pc = abap_false.
    show_only_include = abap_true.
    pc_includes = get_pc_includes( ).
    IF line_exists( pc_includes[ 1 ] ).
      pc_include = pc_includes[ 1 ]-uname.
    ENDIF.
    joblist = get_job_list( ).
    pclist  = get_pc_list( i_refresh = 'X' i_user = pc_include ).

    fill_model( ).

    favicon = `data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAFBklEQVRYR7VXb2xTVRQ/5963rcsMRj9MF/WLQaOJosYgOC` &&
              `WmqBljGQ4l+9NtqDDXhRkTZ9K1Q0g1bl0RZkIy2m4qcfTPnHxA4tQoYsQoSIiJiUYjE4IgMHEYp6lu7bvX87q9+tq9/mGb91N7z7n39zvnnvs79yH8D8` &&
              `PTv28pcPYEY3iXBLAQxGkGcNDRavssHQ4XE39H/8j1Qontoj3rAZAw54wjMWCbttnrf9Iti0agJxBZwaQ4CIilOYK6LCC+tsu+8SvNb1EIeAeDK6VgH9` &&
              `J+V+eZ0csM2H0OysSCCZiD4xSg7BcC9ktUpwisGgE7iVyxgeARp9320IIIePdQ5Dw1cilhkit8raOl7gtjNnoHIuUg5CHKeZKEFGidNwGzyDVwVNVKZ3` &&
              `vzl2ZH0TsQ3g4SXkraEPrmRUCLHDgfFVIWIkKJVkt03SbVuFr5YgZwDdTje+seZAVfG8gdmBeBHf7QLdGLBWfc7trp3buDS6KFWCMAT3a12Y5mK8LETQ` &&
              `F5zOAzfMUEugMhK5NyAyJbRoEXSSlOcY7vRpeWveO2WuPZCHgC4Z0E+ILBx5U3gd5A8E4A5qfF5RlAvmegNjnszcYUJ10TRSjlYZoomp0UMSlvy4uAxx` &&
              `dcTxGHjBVsRkKCjDKJNZ1tto+NdvOrKoed9saGnAS8/tDjEmGY0l2Qp8hMyrh6r6u9eUzzzyBSv6qg3r3V3nwhKwGvf5jABYGDEfySFNIhY1Oj4qpiixI` &&
              `XdXSft9FtWKITpOv4vqvNVpVJJ5gQFZ1bmhLFmJGAWeTkfFZwZbWrpTYRnT5m6+Nz+q9JcYyOopExeTZdns10wpTATORqSto1cARmFUI88s/4j4Nut1uk` &&
              `nHMg9KwE7EOJNhDquTkKmUEn5hCYiRxT0q6DA8h1EuUuCazK2Vr/gZGA2zdUWsSVVQzFL2aRk1CtMdOJFAIZ0x5XVyOHdYh8J22kqd4ZpmB55+aG80YSP` &&
              `f7w/QxBI5bsilraVUYK2Wouz0kCHl9kPTL5trHg9MijF344bSm79Vuy3W4API9Sbo9zfI9SzhTgdUTsFbJr0pwYmjwTAdPIdZ8Ege7B8DKuwjHjPdfBtZ` &&
              `6t+fQGwg/Sjp+Sj2KMOtPvROTUmLL1htlbINETiBwlwBUGVomC08H1eUrx05TiQfrPc5CYEBKqc/WGBIFuf/hRjvCRYcMJydWVrpYZIUkf3b5QBT023yD` &&
              `CN6TbEFHS1RhFGWt32jf+nE+msNcfHqC0PpM8N4R2V6ttT7bFrw4NlcSjrJleOWto7U0Ux190PCfof6SzreFEPsDJbHsCoeO0cLk+IQqU0q5NtZeybUKk` &&
              `qzX7ePTiodc6Ov5+vq+vuNRyXZlrS+OpKwFPHIF3IPwNFQy11oQs0k/lGqe99o9MGxl1gvxVrQFRl/xdcv5wukLmQwapTR4g2Mf+OwLZ5GptDJktztCYz` &&
              `hVyxdqRJs/5gM9kwB/aTMr3umHBOD04VjnaGk8aN/H6IxtIBcM0Z2xMJLmKdT6RJ2vAvXevxTJd9B1N3GwAnECQLzPOD6txvBYg/hR9cDxJduPXzoLBZ4` &&
              `8doMcXfIAx9glN6K+VXBlcUNqNmyeluCcQrqHwImTUPiYzDiq6MYiLSv3BkYtpLntKM/L0B5fTV+2b9Li4w2ThNLXbgZISdetzTU2TuTbO1z6nHY+MjPC` &&
              `x36aqkPEKupc30g35kyE7Th1gf3r3yxckm9+/JTkhob8oRpEAAAAASUVORK5CYII=`.

  ENDMETHOD.


  METHOD get_pc_list.

    DATA: i_t_select      TYPE STANDARD TABLE OF rscedst,
          i_rspcm_include TYPE rspc_monitor_include,
          e_t_logs        TYPE STANDARD TABLE OF rspc_s_monitor.

    IF i_user IS INITIAL.
      i_rspcm_include = sy-uname.
    ELSE.
      i_rspcm_include = i_user.
    ENDIF.

    CALL FUNCTION 'RSPC_API_GET_RECENT_RUNS'
      EXPORTING
        i_rspcm_include = i_user
        i_refresh       = i_refresh
      TABLES
        i_t_select      = i_t_select
        e_t_logs        = e_t_logs.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.

    e_t_pclist = CORRESPONDING #( e_t_logs MAPPING chain_descr = txtlg
                                                   run_status  = analyzed_status
                                                   run_date    = datum
                                                   run_time    = zeit ).

    LOOP AT e_t_pclist ASSIGNING FIELD-SYMBOL(<pc>).
      SELECT SINGLE meta_log, meta_api, meta_remotevar
          FROM rspclogchain
          INTO @DATA(l_pclog)
          WHERE chain_id = @<pc>-chain_id
            AND log_id   = @<pc>-log_id.
      IF sy-subrc = 0 AND ( l_pclog-meta_log = space OR l_pclog-meta_api = 'X' OR
       ( l_pclog-meta_remotevar <> space AND
         l_pclog-meta_remotevar <> <pc>-chain_id ) ).
        <pc>-main = 'X'.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD update_ui_from_model.

    ui_model = model.

    IF show_std_pc = ''.
      DELETE ui_model WHERE is_std_pc = 'X'.
    ENDIF.

    IF show_only_include = 'X'.
      DELETE ui_model WHERE is_in_include = ''.
    ENDIF.

    SORT ui_model BY is_in_include DESCENDING chain_id.

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client = client.
    IF check_initialized = abap_false.
      check_initialized = abap_true.
      on_init( ).
    ENDIF.

    on_event( ).

    update_ui_from_model( ).

    on_view( ).

  ENDMETHOD.


  METHOD on_view.

    DATA(view) = z2ui5_cl_xml_view=>factory( ).

    DATA(z2ui5) = view->_z2ui5( ).
*    DATA(title) = z2ui5->title( |BW Process chain Tool { sy-sysid }| ).
    z2ui5->favicon( favicon ).

    DATA(page) = z2ui5->title( |BW Process chain Tool { sy-sysid }| )->shell(
        )->page(
            title          = |BW Process chain Tool { sy-sysid } |
            navbuttonpress = client->_event( 'BACK' )
            shownavbutton  = abap_false
            showheader     = abap_true
            showsubheader  = abap_true
            showfooter     = abap_true ).

    DATA(head_toolbar) = page->sub_header( )->overflow_toolbar( ).
    head_toolbar->toolbar_spacer(
        )->button( text  = 'Refresh'
                   icon  = 'sap-icon://refresh'
                   press = client->_event( 'ON_BTN_REFRESH_STATUS' )
        )->checkbox( text     = 'Show standard PCs'
                     selected = client->_bind_edit( show_std_pc )
                     select   = client->_event( 'ON_CHK_SHOW_STD' )
        )->checkbox( text     = 'Show only PCs in include'
                     selected = client->_bind_edit( show_only_include )
                     select   = client->_event( 'ON_CHK_SHOW_STD' )
        )->label( text = 'RSPCM Include' labelfor = 'cmbInclude' ).
    DATA(cmb_include) = head_toolbar->combobox( id = `cmbInclude`
                     selectedkey = client->_bind_edit( pc_include )
                     change = client->_event( 'ON_CMB_INCLUDE' ) ).
    LOOP AT pc_includes INTO DATA(l_pc_include).
      cmb_include->item( key = l_pc_include-uname text = l_pc_include-descr ).
    ENDLOOP.


    DATA(tab) = page->table(
                        headertext = 'Process chains'
                        mode = 'MultiSelect'
                        items = client->_bind_edit( ui_model )
                        sticky = 'ColumnHeaders,HeaderToolbar'
                        growing = abap_false ).

    tab->header_toolbar(
            )->toolbar(
                )->title( |List of process chains INCLUDE { pc_include }| ).

    tab->columns(
            )->column( width = '20em' )->text( 'Process chain' )->get_parent(
            )->column( width = '8em'  )->text( 'Job status ' )->get_parent(
            )->column( width = '8em'  )->text( 'Scheduled on (UTC)' )->get_parent(
            )->column( width = '12em' )->text( 'Event and param.' )->get_parent(
            )->column( width = '6em'  )->text( 'Frequency' )->get_parent(
            )->column( width = '8em'  )->text( 'Last run (User)' )->get_parent(
            )->column( width = '8em'  )->text( 'Last run status' )->get_parent(
            )->column( width = '8em'  )->text( 'Next start (start cond.) (UTC)' )->get_parent(
            )->column(  )->text( 'Sched. consistency' )->get_parent(
            )->column(  )->text( 'In include' ).

    tab->items(
         )->column_list_item( selected = '{SELECTED}' type = 'Active' highlight = '{JOB_STATUS_STATE}'
             )->cells(
                 )->object_identifier( title = '{CHAIN_ID}' text = '{CHAIN_DESCR}' )->get_parent(
                 )->object_status( icon = '{JOB_STATUS_ICON}' state = '{JOB_STATUS_STATE}' text = '{JOB_STATUS_TEXT}' )->get_parent(
                 )->text( '{SDLSTRTDT} {SDLSTRTTM}'
                 )->object_attribute( title = '{EVENTID}' text = '{EVENTPARM}'
                 )->text( '{FREQUENCY_TX}'
                 )->text( '{RUN_DATE}  {RUN_TIME}'
                 )->object_status( icon = '{RUN_STATUS_ICON}' state = '{RUN_STATUS_STATE}' text = '{RUN_STATUS_TEXT}' )->get_parent(
                 )->text( '{STARTCOND_SDLSTRTDT} {STARTCOND_SDLSTRTTM}'
                 )->object_status( icon = '{SCHED_STATUS_ICON}' state = '{SCHED_STATUS_STATE}' )->get_parent(
                 )->checkbox( selected = '{IS_IN_INCLUDE}' enabled = abap_false ).


    page->footer( )->overflow_toolbar(
         )->button(
             id = 'test'
             text  = 'Messages'
             press = client->_event( 'ON_MSG_POPOVER' )
             type  = 'Emphasized'
         )->toolbar_spacer(
                )->button(
                    text = |Add to INCLUDE { pc_include }|
                    icon = 'sap-icon://chain-link'
                    press = client->_event( 'ON_BTN_INCLUDE' )
                    enabled = xsdbool( is_not_standard_include( ) )
                )->button(
                    text = |Schedule PC|
                    icon = 'sap-icon://accept'
                    press = client->_event( 'ON_BTN_SCHEDULE' )
                    type = 'Accept'
                )->button(
                    text = 'Unschedule PC'
                    icon = 'sap-icon://decline'
                    press = client->_event( 'ON_BTN_UNSCHEDULE' )
                    type = 'Reject' ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.


  METHOD get_pc_includes.

    SELECT DISTINCT uname, CASE WHEN substring( uname, 1,1 ) = '.' THEN uname ELSE concat( uname,' User specific' ) END, 9
        FROM rspc_monitor
        WHERE uname = @sy-uname OR uname LIKE '.%'
        INTO TABLE @e_t_pc_includes.

    IF line_exists( e_t_pc_includes[  uname = sy-uname ] ).
      e_t_pc_includes[ uname = sy-uname ]-order = 2.
      e_t_pc_includes[ uname = sy-uname ]-descr = |{ sy-uname } My include|.
    ENDIF.

    APPEND VALUE #( uname = '#SCHEDULED' descr = 'Scheduled PCs (#SCHEDULED) !' order = 98 ) TO e_t_pc_includes.
    APPEND VALUE #( uname = '#ALL' descr = 'All PCs (#ALL) !' order = 99 ) TO e_t_pc_includes.

    SORT e_t_pc_includes BY order uname.

  ENDMETHOD.



  METHOD get_next_start_date.

    TYPES: BEGIN OF t_period,
             prdmins    TYPE btcpmin,
             prdhours   TYPE btcphour,
             prddays    TYPE btcpday,
             prdweeks   TYPE btcpweek,
             prdmonths  TYPE btcpmnth,
             emergmode  TYPE tbtco-emergmode,
             calendarid TYPE tbtco-calendarid,
             prdbehav   TYPE tbtco-prdbehav,
             calcorrect TYPE tbtco-calcorrect,
             eomcorrect TYPE tbtco-eomcorrect,
           END OF t_period.
    TYPES: BEGIN OF t_start_cond,
             sdlstrtdt  TYPE tbtco-sdlstrtdt,
             sdlstrttm  TYPE tbtco-sdlstrttm,
             laststrtdt TYPE tbtco-laststrtdt,
             laststrttm TYPE tbtco-laststrttm,
           END OF t_start_cond.

    DATA(curr_date) = sy-datum.
    DATA(curr_time) = sy-uzeit.
    DATA: e_s_trigger TYPE rspctrigger,
          e_t_trigger TYPE TABLE OF rspctrigger.

    DATA: l_prd     TYPE t_period,
          next_strt TYPE t_start_cond,
          safe_date TYPE sydatum.

    safe_date = sy-datum + 7300.   "20 years from now...

    CALL FUNCTION 'RSPC_API_CHAIN_GET_STARTCOND'
      EXPORTING
        i_chain     = chain_id
      IMPORTING
        e_s_trigger = e_s_trigger.
*      TABLES
*        e_t_trigger = e_t_trigger.
    IF sy-subrc = 0 AND e_s_trigger-startdttyp = 'D'.  "Only direct scheduling
      l_prd = CORRESPONDING #( e_s_trigger ).
      next_strt = CORRESPONDING #( e_s_trigger ).

      DO.

        IF next_strt-sdlstrtdt >= safe_date.
          EXIT.
        ENDIF.

        PERFORM calculate_next_date IN PROGRAM saplbtch
          USING e_s_trigger-sdlstrtdt e_s_trigger-sdlstrttm e_s_trigger-sdlstrtdt
          CHANGING l_prd next_strt.
        IF next_strt-sdlstrtdt > curr_date OR ( next_strt-sdlstrtdt = curr_date AND next_strt-sdlstrttm > curr_time ).
          EXIT.
        ENDIF.
        e_s_trigger-sdlstrtdt = next_strt-sdlstrtdt.
        e_s_trigger-sdlstrttm = next_strt-sdlstrttm.
      ENDDO.
      e_s_next_start = CORRESPONDING #( next_strt ).
    ENDIF.
  ENDMETHOD.


  METHOD schedule_chain.

    CALL FUNCTION 'RSPC_API_CHAIN_SCHEDULE'
      EXPORTING
        i_chain    = chain_id
        i_periodic = abap_true.
    e_retcode = sy-subrc.
  ENDMETHOD.


  METHOD unschedule_chain.

    CALL FUNCTION 'RSPC_API_CHAIN_INTERRUPT'
      EXPORTING
        i_chain = chain_id
        i_kill  = abap_false
      EXCEPTIONS
        failed  = 4.

    e_retcode = sy-subrc.

  ENDMETHOD.


  METHOD display_msg_popover.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( ).

    popup->message_popover(
            items      = client->_bind_edit( msgs )
            groupitems = abap_false
            placement = `Top`
            initiallyexpanded = abap_true
            beforeclose = client->_event( val = 'ON_MSG_POPOVER_CLOSE' s_ctrl = VALUE #( check_view_destroy = abap_false ) )
        )->message_item(
            type        = `{TYPE}`
            title       = `{TITLE}`
*            subtitle    = `{SUBTITLE}`
*            description = `{DESCRIPTION}`
*            groupname   = `{GROUP}`
        ).

    client->popover_display( xml = popup->stringify( ) by_id = id ).

  ENDMETHOD.


  METHOD schedule_unschedule_chains.

    DATA: retcode     TYPE syst_subrc,
          action_text TYPE string.

    LOOP AT chain_id_list INTO DATA(l_chain_id).

      CASE action.
        WHEN 'SCHEDULE'.
          IF l_chain_id-job_status <> 'S'.  "If job already scheduled do nothing
            retcode = schedule_chain( EXPORTING chain_id = l_chain_id-chain_id ).
            action_text = 'Scheduling'.
          ELSE.
            action_text = 'PC already scheduled'.
            retcode = 99.
          ENDIF.
        WHEN 'UNSCHEDULE'.
          IF l_chain_id-job_status = 'S'.  "If job is unscheduled, do nothing
            retcode = unschedule_chain( EXPORTING chain_id = l_chain_id-chain_id ).
            action_text = 'Unscheduling'.
          ELSE.
            action_text = 'PC already unscheduled'.
            retcode = 99.
          ENDIF.
        WHEN OTHERS.
          action_text = 'Unknown ACTION'.
      ENDCASE.

      add_message( i_title = |{ action_text } { l_chain_id-chain_id }|
                   i_retcode = retcode ).

    ENDLOOP.


  ENDMETHOD.

  METHOD refresh_model.

    joblist = get_job_list( ).
    pclist = get_pc_list( i_refresh = i_refresh i_user = i_user ).
    fill_model( ).

  ENDMETHOD.


  METHOD add_message.

    msgs = VALUE #( BASE msgs ( title = i_title
*                                  subtitle = 'Subtitle'
*                                  description = |Scheduling { l_chain_id-chain_id }|
                                type = COND #( WHEN i_retcode = 0  THEN 'Success'
                                               WHEN i_retcode = 99 THEN 'Information'
                                               ELSE                     'Error' ) ) ).

  ENDMETHOD.

ENDCLASS.
