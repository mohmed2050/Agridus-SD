import 'package:flutter/material.dart';

class ExtensionScreen extends StatelessWidget {
  const ExtensionScreen({super.key});

  static const _cropNames = ['أبو سبعين', 'الفول السوداني', 'القمح', 'السمسم', 'البرسيم'];

  static const _cropData = {
    'أبو سبعين': {
      'مقدمة': 'يعتبر الذرة الرفيعة (أبو سبعين) المحصول الغذائي الأول في السودان، يزرع في معظم الولايات.',
      'الأصناف': 'أبو سبعين - فترريتا - وادي النيل - أربع جمعة - د精美',
      'تحضير الأرض': 'حرث عميق 30 سم + تسطيب + تزعيب. يفضل الحرث بعد هطول الأمطار.',
      'طريقة الزراعة': 'زراعة على خطوط 70-80 سم بين الخطوط، 20 سم بين الجور. 3-5 بذور في الجورة.',
      'الري': 'الري الأول بعد الزراعة مباشرة، ثم كل 7-10 أيام. المطرية تحتاج 3-4 ريات.',
      'التسميد': '50 كجم يوريا/فدان بعد 21 يوم + 50 كجم يوريا/فدان بعد 45 يوم.',
      'الآفات': 'المن - دودة الحشد - طيور - حشرة أبو الدقيق.',
      'الحصاد': 'بعد 90-120 يوم. علامات النضج: جفاف القنابع وتصلب الحبوب.'
    },
    'الفول السوداني': {
      'مقدمة': 'محصول زيتي وتصديري هام في السودان، يتركز في كسلا والقضارف والنيل الأزرق.',
      'الأصناف': 'أشرفي - باربيرتون - جبريل - مدني - صنهوت.',
      'تحضير الأرض': 'حرث عميق + تسطيب. تربة رملية طينية خفيفة جيدة الصرف.',
      'طريقة الزراعة': 'زراعة في سطور 60 سم بين السطور، 15-20 سم بين الجور. بذرتين في الجورة.',
      'الري': 'ري خفيف كل 7 أيام. يفضل الري بالتنقيط لزيادة الإنتاجية.',
      'التسميد': 'سوبر فوسفات 100 كجم/فدان + يوريا 20 كجم/فدان بعد 21 يوم.',
      'الآفات': 'تبقع الأوراق - الصدأ - عفن الجذور - حشرات التربة.',
      'الحصاد': 'بعد 120-150 يوم. عند اصفرار الأوراق وجفاف القرون.'
    },
    'القمح': {
      'مقدمة': 'محصول استراتيجي في السودان، يزرع شتوياً في مشاريع الري الكبرى.',
      'الأصناف': 'دلتا - ساجدي - ود البشير - خلفا - ديماس.',
      'تحضير الأرض': 'حرث جيد + تسطيب دقيق. تربة طينية ثقيلة جيدة الصرف.',
      'طريقة الزراعة': 'بدار (نثر) أو زراعة على خطوط 20 سم. معدل التقاوي: 50 كجم/فدان.',
      'الري': 'الري الأول بعد الزراعة مباشرة. يروى كل 7-10 أيام (6-8 ريات في الموسم).',
      'التسميد': 'يوريا 100 كجم/فدان على دفعتين: 21 و 45 يوم. سوبر فوسفات 50 كجم/فدان.',
      'الآفات': 'الصدأ الأصفر - البياض الدقيقي - المن - دودة الحشد.',
      'الحصاد': 'بعد 120-150 يوم. عند اصفرار السنابل وجفاف الحبوب.'
    },
    'السمسم': {
      'مقدمة': 'محصول زيتي وتصديري رئيسي، يتحمل الجفاف ويزرع في المناطق المطرية.',
      'الأصناف': 'بحر - دندرة - زهرة - ود النيل - أربع جمعة.',
      'تحضير الأرض': 'حرث خفيف + تسطيب. تربة خفيفة جيدة الصرف. يفضل عدم الإفراط في الحرث.',
      'طريقة الزراعة': 'زراعة على خطوط 60-70 سم. 3-5 بذور في الجورة. أو بدار بنثر التقاوي.',
      'الري': 'المطرية: ري تكميلي عند الحاجة. المروية: ري خفيف كل 7-10 أيام.',
      'التسميد': 'يحتاج القليل من السماد. سوبر فوسفات 50 كجم/فدان يرفع الإنتاج.',
      'الآفات': 'تبقع الأوراق - الذبول - دودة ورق القطن.',
      'الحصاد': 'بعد 90-120 يوم. عند جفاف الأوراق السفلية وتشقق الكبسولات.'
    },
    'البرسيم': {
      'مقدمة': 'محصول علفي هام للماشية، يزرع في مشاريع الري ويساهم في تثبيت النيتروجين.',
      'الأصناف': 'هجين - محلي - ود مدني - الأبيض.',
      'تحضير الأرض': 'حرث عميق + تسطيب. تربة طينية جيدة الصرف.',
      'طريقة الزراعة': 'بدار نثر أو زراعة على خطوط 20-30 سم. معدل التقاوي 15 كجم/فدان.',
      'الري': 'ري كل 7 أيام صيفاً و 10 أيام شتاءً. البرسيم حساس للعطش.',
      'التسميد': 'سوبر فوسفات 100 كجم/فدان قبل الزراعة. لا يحتاج نيتروجين.',
      'الآفات': 'المن - البياض الدقيقي - حفار أوراق البرسيم.',
      'الحصاد': 'أول حشة بعد 60 يوم. ثم كل 25-30 يوم. 6-8 حشات في السنة.'
    },
  };

  static const _emergencyData = [
    {'title': 'التسمم بالمبيدات - إسعافات أولية', 'body': '1. اتصل بالإسعاف فوراً\n2. انقل المصاب للهواء الطلق\n3. اخلع الملابس الملوثة\n4. اغسل الجلد بالماء والصابون\n5. لا تحفز التقيؤ إلا بتعليمات طبية\n6. احتفظ بعبوة المبيد للتعريف'},
    {'title': 'الإدارة العامة لوقاية النباتات', 'body': 'الخرطوم - تلفون: 0183745678\nفاكس: 0183745679\nالبريد: plant.protection@sudanagri.sd'},
    {'title': 'هيئة الأرصاد الجوية السودانية', 'body': 'الخرطوم - تلفون: 0183771234\nالإنذار المبكر: 0183771235\nخدمة المزارعين: 0183771236'},
    {'title': 'غرفة طوارئ الآفات الزراعية', 'body': 'بلاغات تفشي الآفات:\nتلفون: 0183745680\nواتساب: 0912345678\nطوارئ 24 ساعة: 0900567890'},
    {'title': 'مديريات الزراعة بالولايات', 'body': 'الخرطوم: 0183772000\nالقضارف: 0441123456\nكسلا: 0442123456\nالنيل الأزرق: 0541123456\nسنار: 0542123456\nالشمالية: 0241123456'},
    {'title': 'الطوارئ العامة', 'body': 'الدفاع المدني: 998\nالإسعاف: 999\nالشرطة: 999\nالمستشفى البيطري: 0183777000'},
  ];

  static const _seasonalData = [
    {'crop': 'أبو سبعين', 'plant': 'يونيو - يوليو', 'grow': '90-120 يوم', 'harvest': 'أكتوبر - ديسمبر', 'color': '0xFFFFA726'},
    {'crop': 'الفول السوداني', 'plant': 'يونيو - يوليو', 'grow': '120-150 يوم', 'harvest': 'نوفمبر - يناير', 'color': '0xFF66BB6A'},
    {'crop': 'القمح', 'plant': 'نوفمبر - ديسمبر', 'grow': '120-150 يوم', 'harvest': 'مارس - أبريل', 'color': '0xFF42A5F5'},
    {'crop': 'السمسم', 'plant': 'يوليو - أغسطس', 'grow': '90-120 يوم', 'harvest': 'نوفمبر - ديسمبر', 'color': '0xFFAB47BC'},
    {'crop': 'البرسيم', 'plant': 'سبتمبر - أكتوبر', 'grow': '60 يوم (حشة)', 'harvest': 'طوال العام', 'color': '0xFF26A69A'},
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('الإرشاد الزراعي'),
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            bottom: const TabBar(
              isScrollable: true,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: [
                Tab(text: 'الإرشاد', icon: Icon(Icons.menu_book, size: 18)),
                Tab(text: 'الطوارئ', icon: Icon(Icons.warning, size: 18)),
                Tab(text: 'التقويم الموسمي', icon: Icon(Icons.calendar_month, size: 18)),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              _ExtensionTab(),
              _EmergencyTab(),
              _SeasonalTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExtensionTab extends StatelessWidget {
  const _ExtensionTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: ExtensionScreen._cropNames.length,
      itemBuilder: (context, i) {
        final name = ExtensionScreen._cropNames[i];
        final data = ExtensionScreen._cropData[name]!;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Text('${i + 1}', style: TextStyle(color: Colors.green.shade700)),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${data['مقدمة']!.substring(0, 50)}...'),
            children: data.entries.map((e) {
              if (e.key == 'مقدمة') return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.key,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700)),
                    const SizedBox(height: 4),
                    Text(e.value, textAlign: TextAlign.justify),
                    const Divider(),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _EmergencyTab extends StatelessWidget {
  const _EmergencyTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: ExtensionScreen._emergencyData.length,
      itemBuilder: (context, i) {
        final item = ExtensionScreen._emergencyData[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.red.shade100,
              child: Icon(Icons.warning_amber, color: Colors.red.shade700),
            ),
            title: Text(item['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(item['body']!, textAlign: TextAlign.start),
            ),
          ),
        );
      },
    );
  }
}

class _SeasonalTab extends StatelessWidget {
  const _SeasonalTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('التقويم الموسمي للمحاصيل',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...ExtensionScreen._seasonalData.map((s) {
                    final months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
                        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
                    final color = Color(int.parse(s['color']!.replaceFirst('0x', '0xFF')));
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s['crop']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Row(children: [
                            const SizedBox(width: 60, child: Text('الزراعة:', style: TextStyle(fontSize: 12))),
                            Expanded(child: Text(s['plant']!, style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
                          ]),
                          Row(children: [
                            const SizedBox(width: 60, child: Text('النمو:', style: TextStyle(fontSize: 12))),
                            Expanded(child: Text(s['grow']!, style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
                          ]),
                          Row(children: [
                            const SizedBox(width: 60, child: Text('الحصاد:', style: TextStyle(fontSize: 12))),
                            Expanded(child: Text(s['harvest']!, style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
                          ]),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 20,
                            child: Row(children: months.map((m) {
                              final planting = s['plant']!.contains(m);
                              final harvest = s['harvest']!.contains(m);
                              Color bg = Colors.grey.shade200;
                              if (planting) bg = Colors.green;
                              if (harvest) bg = color;
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    color: bg,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              );
                            }).toList()),
                          ),
                          const SizedBox(height: 4),
                          Row(children: [
                            Row(children: [
                              Container(width: 10, height: 10, color: Colors.green),
                              const SizedBox(width: 4),
                              const Text('زراعة', style: TextStyle(fontSize: 10)),
                            ]),
                            const SizedBox(width: 16),
                            Row(children: [
                              Container(width: 10, height: 10, color: color),
                              const SizedBox(width: 4),
                              const Text('حصاد', style: TextStyle(fontSize: 10)),
                            ]),
                          ]),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
