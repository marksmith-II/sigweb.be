class ZCL_ZTOPAZ_SIG_UPLOAD_DPC_EXT definition
  public
  inheriting from ZCL_ZTOPAZ_SIG_UPLOAD_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_STREAM
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZTOPAZ_SIG_UPLOAD_DPC_EXT IMPLEMENTATION.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_STREAM.
*BDS handling
    CONSTANTS:
      bds_classname TYPE sbdst_classname VALUE 'DEVC_STXD_BITMAP',
      bds_classtype TYPE sbdst_classtype VALUE 'OT',          " others
      bds_mimetype  TYPE bds_mimetp      VALUE 'application/octet-stream',
      temp2(5)      TYPE c VALUE ' ''',
      temp1(5)      TYPE c VALUE '''',
      autoheight    TYPE stxbitmaps-autoheight VALUE 'X', "reserve
      bmcomp        TYPE stxbitmaps-bmcomp VALUE 'X', "compress
      object        TYPE stxbitmaps-tdobject VALUE 'GRAPHICS',
      id            TYPE stxbitmaps-tdid VALUE 'BMAP',
      btype         TYPE stxbitmaps-tdbtype VALUE 'BMON',
      title         TYPE bapisignat-prop_value VALUE 'Signature'.

* for uploading the signature
    DATA:
      filename   TYPE rlgrap-filename,      "path & name of bmp
      name       TYPE stxbitmaps-tdname,    "saved bmp name
      resident   TYPE stxbitmaps-resident,
      resolution TYPE stxbitmaps-resolution,
      lt_flines  TYPE STANDARD TABLE OF tline,
      ls_flines  TYPE tline,
      name_text  TYPE thead-tdname,
      object_key TYPE sbdst_object_key.
    DATA:
      docid         TYPE stxbitmaps-docid,
      width_tw      TYPE stxbitmaps-widthtw,
      height_tw     TYPE stxbitmaps-heighttw,
      width_pix     TYPE stxbitmaps-widthpix,
      height_pix    TYPE stxbitmaps-heightpix,
      color         TYPE c LENGTH 1,
      bds_bytecount TYPE i.

    TYPES: BEGIN OF zst_ts_raw_line,
             line(2550) TYPE x,
           END OF zst_ts_raw_line.
    DATA: tech_request    TYPE REF TO /iwbep/cl_mgw_request,
          delivery_number TYPE vbeln.

    DATA: wa_bintab TYPE zst_ts_raw_line,
          bintab    TYPE  zst_ts_raw_line,
          bintabs   TYPE TABLE OF zst_ts_raw_line,
          binlen    TYPE  i,
          b64Value  TYPE string,
          doc       TYPE zcl_ztopaz_sig_upload_mpc=>ts_deliverydocument.

*M1 START
    DATA: lv_width           TYPE i,
          lv_height          TYPE i,
          lv_handle          TYPE i,
          lo_image_processor TYPE REF TO cl_fxs_image_processor.



    DATA:
      lo_bds_object     TYPE REF TO cl_bds_document_set,
      lt_bds_content    TYPE sbdst_content,
      lt_bds_components TYPE sbdst_components,
      wa_bds_components TYPE LINE OF sbdst_components,
      lt_bds_signature  TYPE sbdst_signature,
      wa_bds_signature  TYPE LINE OF sbdst_signature,
      lt_bds_properties TYPE sbdst_properties,
      wa_bds_properties TYPE LINE OF sbdst_properties,
      wa_stxbitmaps     TYPE stxbitmaps.

    DATA: lt_bin_data TYPE esy_tt_rcgrepfile,
          lv_bin_len  TYPE i,
          lv_return   TYPE bal_s_msg,
          ls_msg      TYPE bal_s_msg,
          it_bin_sig  TYPE esy_tt_rcgrepfile,
          lv_xstring     TYPE xstring,
          lv_base64_string TYPE string.


  DATA: jobname   TYPE tbtcjob-jobname,
        jobcount  TYPE tbtcjob-jobcount.

    TYPES: BEGIN OF ty_data,
             field1 TYPE string,
             field2 TYPE i,
           END OF ty_data.

    DATA(request_headers) = io_tech_request_context->get_request_headers( ).
    TRY.

        delivery_number = request_headers[ name = 'documentnumber' ]-value.

      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

* Read the base64 data from UI5 in xstring
    lv_xstring  = is_media_resource-value.
*    data(lo_convert)  = cl_abap_conv_in_ce=>create( ).

*   convert the xstring value to base64 string
*    lo_convert->convert( EXPORTING input = lv_xstring
*                          IMPORTING data  = lv_base64_string ).


*    CALL FUNCTION 'SCMS_BASE64_DECODE_STR'
*      EXPORTING
*        input  = lv_base64_string
**       UNESCAPE       = 'X'
*      IMPORTING
*        output = lv_xstring
** EXCEPTIONS
**       FAILED = 1
**       OTHERS = 2
*      .
*    IF sy-subrc <> 0.
** Implement suitable error handling here
*    ENDIF.


*    DATA(xstring) = is_media_resource-value.

    lv_width = 900.
    lv_height = 240.

    CREATE OBJECT lo_image_processor TYPE cl_fxs_image_processor.

    TRY.
        CALL METHOD lo_image_processor->add_image
          EXPORTING
            iv_data   = lv_xstring
*           iv_image_name = lv_file_name
          RECEIVING
            rv_handle = lv_handle.

        CALL METHOD lo_image_processor->resize
          EXPORTING
            iv_handle = lv_handle
            iv_xres   = lv_width
            iv_yres   = lv_height.

        CALL METHOD lo_image_processor->convert
          EXPORTING
            iv_handle     =  lv_handle
            iv_format     =  cl_fxs_mime_types=>co_image_bitmap
*            iv_otf_adjust = abap_false
          .
*        CATCH cx_sy_range_out_of_bounds. " System Exceptions Accessing Subfields Beyond Boundary

        CALL METHOD lo_image_processor->get_image
          EXPORTING
            iv_handle  = lv_handle
          RECEIVING
            rv_xstring = lv_xstring.

      CATCH cx_fxs_image_unsupported INTO DATA(error_message) .
*        xstring = ev_xstring.
      CATCH cx_sy_range_out_of_bounds .
*        xstring = ev_xstring.
    ENDTRY.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = lv_xstring
      IMPORTING
        output_length = binlen
      TABLES
        binary_tab    = lt_bin_data.



    CALL FUNCTION 'Z_CC_CREATE_SIGNATURE_TEXT'
      EXPORTING
        it_bin_sig = lt_bin_data
        iv_bin_len = binlen
        iv_vbeln   = delivery_number
      IMPORTING
        es_return  = lv_return
*       EV_SUBRC   = ev_subrc
      .

    doc-delivery_number = delivery_number.
** PGI
*    SELECT *
*      FROM likp
*      WHERE vbeln = @delivery_number
*      INTO TABLE @DATA(likp).
*
*      READ TABLE likp ASSIGNING FIELD-SYMBOL(<delivery>) INDEX 1.
*      IF sy-subcs = 0.
*        <delivery>-zzcustsigdat = sy-datlo.
*        <delivery>-zzcustsigtim = sy-timlo.
*        ENDIF.
*        CONCATENATE 'POD' delivery_number INTO jobname.
*
*                    CALL FUNCTION 'JOB_OPEN'
*              EXPORTING
*                jobname  = jobname
*              IMPORTING
*                jobcount = jobcount.
*
*            SUBMIT z_cc_finalize_delivery WITH p_vbeln  = delivery_number
*            VIA JOB jobname NUMBER jobcount
*            USER sy-uname
*            AND RETURN.
*
** Schedule and close job.
*            CALL FUNCTION 'JOB_CLOSE'
*              EXPORTING
*                jobcount  = jobcount
*                jobname   = jobname
*                sdlstrtdt = sy-datum
*                sdlstrttm = sy-uzeit.


    copy_data_to_ref(
      EXPORTING
        is_data = doc
      CHANGING
        cr_data = er_entity ).


  endmethod.
ENDCLASS.
