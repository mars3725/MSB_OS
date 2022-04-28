import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:msb_os/main.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({Key? key}) : super(key: key);
  final double scale = 2;

  @override
  _ScheduleViewState createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('robots').doc(robotID).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong',
                style: TextStyle(color: Colors.white, fontSize: 24)
              ));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            List<Widget> times = List.generate(24, (index) => Positioned(
              top: 60*widget.scale*index,
              left: 15,
              height: 60*widget.scale,
              width: MediaQuery.of(context).size.width-30,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white, height: 2, thickness: 2),
                  SizedBox(
                      height: 60*widget.scale-2,
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                          TimeOfDay(hour: index, minute: 0).format(context).splitMapJoin(':00', onMatch: (match) => ''),
                          style: const TextStyle(fontSize: 18, color: Colors.white)
                      )),
                ],
              ),
            ));

            List<Widget> events = [];
            snapshot.data!.get('events').asMap().forEach((index, event) {
              events.add(Positioned(
                top: event['start']*widget.scale,
                left: MediaQuery.of(context).size.width*1/3-15,
                child: Container(
                  width: MediaQuery.of(context).size.width*2/3,
                  height: (event['end'] - event['start'])*widget.scale,
                  color: Theme.of(context).colorScheme.primary,
                  child: Center(child: Text(
                      event['name'],
                      style: const TextStyle(fontSize: 24)
                  )),
                ),
              ));
            });

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                          onPressed: ()=> Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.white, size: 48)
                      ),
                      const Expanded(
                        child: Text('Schedule', textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                const Padding(padding: EdgeInsets.all(15)),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: ScrollController(
                        initialScrollOffset: 60*widget.scale*TimeOfDay.now().hour,
                        keepScrollOffset: true
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 120*24,
                      child: Stack(
                        children: [...times,
                          ...events,
                          Positioned(
                          top: 60*widget.scale*TimeOfDay.now().hour+TimeOfDay.now().minute,
                          left: 15,
                          height: 60*widget.scale,
                          width: MediaQuery.of(context).size.width-30,
                          child: const Divider(color: Colors.orange, height: 4, thickness: 4),
                        )],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        )
    );
  }
}
