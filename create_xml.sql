    function report_xml
        return xmltype is
        l_xml            xmltype;
        l_header         xmltype;
        l_items          xmltype;
        l_translations   xmltype;
    begin
        select xmlelement(
                   "header",
                   xmlelement("date_from", g_date_from),
                   xmlelement("date_to", g_date_to),
                   xmlelement("legal_entity", l.legal_entity_name),
                   xmlelement("user_name",
                              (select nvl(p.full_name, u.description) as user_name
                                 from apps.fnd_user u,
                                      hr.per_all_people_f p
                                where u.user_id = apps.fnd_profile.value('USER_ID') and u.employee_id = p.person_id(+))
                             ),
                   xmlelement("products_number",
                              (select count(distinct inventory_item_num)
                                 from xxopm.xxopm_b194_report_t)
                             )
               )
          into l_header
          from apps.gmf_legal_entities l
         where legal_entity_id = g_legal_entity_id;

        with items as
                 (  select inventory_item_num,
                           inventory_item_name,
                           xmlagg(
                               xmlelement(
                                   "period",
                                   xmlforest(
                                       decode(period_type,  'YTD', inventory_item_num,  'CURRENT', inventory_item_name) as "inventory_item",
                                       period_type as "period_type",
                                       xxopm.xxopm_b194_pkg.translate_msg(period_type) as "period_type_name",
                                       num_to_char(ingoing_quantity) as "ingoing_quantity",
                                       num_to_char(ingoing_value) as "ingoing_value",
                                       num_to_char(purchase_value) as "purchase_value",
                                       num_to_char(outgoing_quantity) as "outgoing_quantity",
                                       num_to_char(sales_quantity) as "sales_quantity",
                                       num_to_char(sales_value) as "sales_value",
                                       num_to_char(sales_cost) as "sales_cost",
                                       num_to_char(outgoing_cost) as "outgoing_cost",
                                       num_to_char(gross_result) as "gross_result",
                                       num_to_char(balance_quantity) as "balance_quantity",
                                       num_to_char(balance_value) as "balance_value"
                                   )
                               )
                               order by decode(period_type,  'YTD', 1,  'CURRENT', 2,  'TOTAL', 3)
                           )
                               as periods
                      from xxopm.xxopm_b194_report_t
                  group by inventory_item_num,
                           inventory_item_name)
        select xmlelement(
                   "items",
                   xmlagg(
                       xmlelement(
                           "item",
                           xmlforest(i.inventory_item_num as "inventory_item_num",
                                     i.inventory_item_name as "inventory_item_name",
                                     i.periods as "periods"
                                    )
                       )
                       order by
                           i.inventory_item_num,
                           i.inventory_item_name
                   )
               )
          into l_items
          from items i;

        select xmlelement("translations", xmlagg(xmlelement(evalname (replace(m.message_key, ' ', '_')), m.text)))
          into l_translations
          from xxapps.xxapps_a003_translate_msg_ft m
         where form_name = 'XXOPM_B194' and language = userenv('LANG');

        select xmlroot(xmlelement("report", xmlconcat(xmlsequencetype(l_header, l_items, l_translations))),
                       version '1.0'
                      )
          into l_xml
          from dual;

        return l_xml;
    end;