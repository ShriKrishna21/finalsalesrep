import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/agent/coustmerform.dart';
import 'package:finalsalesrep/agent/historypage.dart';
import 'package:finalsalesrep/agent/onedayhistory.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Agentscreen extends StatefulWidget {
  const Agentscreen({super.key});

  @override
  State<Agentscreen> createState() => _AgentscreenState();
}

class _AgentscreenState extends State<Agentscreen> {
  TextEditingController dateController = TextEditingController();
  int todaycount = 0;
  int alreadysubscribed = 0;
  int offeraccepted = 0;
  int offerrejected = 0;
  String agentname="";

  void initState() {
    super.initState();
    String formattedDate = DateFormat('EEE- MMMM d, y').format(DateTime.now());
    dateController.text = formattedDate;
    count();
  }

  count() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setInt('offer_accepted', accepted);
    //     await prefs.setInt('offer_rejected', rejected);
    //     await prefs.setInt('already_subscribed', subscribed);
    final todaycounrt = prefs.getInt('today_count');
    final alreadysubsccribedd = prefs.getInt('already_subscribed');
    final offeracceptedd = prefs.getInt('offer_accepted');
    final offerrejectedd = prefs.getInt('offer_rejected');
    final agent =prefs.getString("username");

    setState(() {
      todaycount = todaycounrt ?? 0;
      alreadysubscribed = alreadysubsccribedd ?? 0;
      offeraccepted = offeracceptedd ?? 0;
      offerrejected = offerrejectedd ?? 0;
      agentname =agent??"";
    });

    print("Today Count: $todaycount");
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 12,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => agentProfile(),
                    ));
              },
              child: Icon(
                Icons.person,
                size: MediaQuery.of(context).size.height / 16,
              ))
        ],
        centerTitle: true,
        title: Column(
          children: [
            Text(
              "Sales Rep",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height / 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text("Welcome $agentname",style: TextStyle(color: Colors.black,fontSize: 30,fontWeight: FontWeight.bold),)
          ],
        ),
      ),
      drawer: Drawer(
        child: DrawerHeader(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
                child: Image(
                  image: AssetImage("assets/images/logo.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Historypage(),
                      ));
                },
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.stacked_bar_chart,
                        color: Color.fromARGB(
                          255,
                          67,
                          138,
                          254,
                        ),
                      ),
                    ),
                    const Text(
                      "History Page",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => Coustmer()));
        },
        label: const Text(
          "Customer Form",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        icon: const Icon(
          Icons.add_box_outlined,
          color: Colors.white,
        ),
        backgroundColor: const Color.fromARGB(
          255,
          67,
          138,
          254,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 50),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 50,
            ),
            Container(
              height: 55,
              width: 400,
              decoration: BoxDecoration(
                  border: Border.all(width: 1.8),
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey.shade500),
              child: Center(
                child: Text(
                  dateController.text,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Onedayhistory(),
                        ));
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height / 6.33,
                    width: 190,
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black,
                              blurRadius: 10,
                              offset: const Offset(3, 3))
                        ],
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20)),
                        color: Colors.white),
                    child: Column(
                      children: [
                        //   2nd  House Visited Container
                        Container(
                          height: 60,
                          width: 200,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                              ),
                              color: Colors.white),
                          child: const Center(
                              child: Text(
                            "HouseVisited",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          )),
                        ),
                        //today Container
                        Container(
                          height: 80,
                          width: 200,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(

                                  // topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20)),
                              border: Border(
                                  top: BorderSide(
                                      color: Colors.black, width: 2)),
                              color: Color.fromARGB(255, 178, 255, 87)),
                          child: Center(
                              child: Text(
                            "Today: ${todaycount}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  height: MediaQuery.of(context).size.height / 6.33,
                  width: 190,
                  decoration: BoxDecoration(
                      border: Border.all(
                        width: 2.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 10,
                            offset: const Offset(3, 3))
                      ],
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20)),
                      color: Colors.white),
                  child: Column(
                    children: [
                      //   2nd  House Visited Container

                      Container(
                          height: 60,
                          width: 200,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                              ),
                              color: Colors.white),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Target Left",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          )),
                      //today Container
                      Container(
                        height: 80,
                        width: 200,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20),
                            ),
                            border: Border(
                                top: BorderSide(color: Colors.black, width: 2)),
                            color: Color.fromARGB(
                              255,
                              252,
                              83,
                              80,
                            )),
                        child: Center(
                          child: Text(
                            "Today:${40 - todaycount}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Column(
              children: [
                //   2nd  House Visited Container
                Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(width: 2.5),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 10,
                            offset: Offset(1, 1))
                      ],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      color: Colors.white),
                  child: const Center(
                      child: Text(
                    "My Route Map",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  )),
                ),
                //today Container
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 10,
                            offset: Offset(1, 1))
                      ],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      border: Border(
                          top: BorderSide(color: Colors.black, width: 2)),
                      color: Color.fromARGB(
                        255,
                        82,
                        64,
                        112,
                      )),
                  child: const Center(
                    child: Text(
                      "NA",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 10,
                            offset: Offset(5, 5))
                      ],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20)),
                      color: Colors.white),
                  child: Column(
                    children: [
                      //   2nd  House Visited Container
                      Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 10,
                                  offset: Offset(1, 1))
                            ],
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20)),
                            color: Colors.white),
                        child: const Center(
                            child: Text(
                          "Reports",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        )),
                      ),
                      //today Container
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 10,
                                  offset: Offset(1, 1))
                            ],
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            border: Border(
                                top: BorderSide(color: Colors.black, width: 2)),
                            color: Color.fromARGB(
                              255,
                              92,
                              29,
                              74,
                            )),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Already Subscribed  : $alreadysubscribed   ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white),
                              ),
                              Text(
                                "Offer Accepted     : $offeraccepted ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white),
                              ),
                              Text(
                                "Offer Rejected      :   $offerrejected ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
