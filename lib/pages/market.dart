import 'package:agri_app/services/listService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketPlace extends StatefulWidget {
  const MarketPlace({Key? key}) : super(key: key);

  @override
  _MarketPlaceState createState() => _MarketPlaceState();
}

class _MarketPlaceState extends State<MarketPlace> {

  bool isSearch=false;
  TextEditingController searchController=TextEditingController();
  ListService listService=ListService();
  bool loading=true;
  dynamic result=[];
  String txt="Loading";
  String url = "http://10.0.2.2:3000";

  @override
  void initState() {
    init();
    SharedPreferences.getInstance().then((value) {
      url = value.getString("url").toString();
    });
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void init({String query=""})async{
    result=await listService.getItems(query: query);
    print(result);
    if(result!="error"){
      setState(() {
        loading=false;
        txt="Loading";
      });
    }
    else{
      setState(() {
        txt="Loading...";
      });
      Future.delayed(Duration(seconds: 5),(){init(query: query);});
    }
  }


  showPic(BuildContext context,String url){
    AlertDialog alert =AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(
        height: 200,
        width: 100,
        padding: EdgeInsets.zero,
        child: Image.network(url,fit: BoxFit.cover,),
      ),
    );

    showDialog(context: context,builder:(BuildContext context){
      return alert;
    });
  }

  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        if(isSearch) {
          searchController.clear();
          setState(() {
            isSearch = false;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.green,
          ),
          automaticallyImplyLeading: !isSearch,
          title: isSearch?Container(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            width: MediaQuery.of(context).size.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.text,
                    autofocus: true,
                    style: TextStyle(color: Colors.green),
                    controller: searchController,
                    decoration: InputDecoration(border: InputBorder.none,hintText: "Search"),
                    onChanged: (text){
                      setState(() {});
                    },
                    onSubmitted: (text){
                      setState(() {
                        loading=true;
                        isSearch=false;
                        result=[];
                      });
                      init(query: text);
                    },
                  ),
                ),
                searchController.text.length!=0?IconButton(onPressed: (){searchController.clear();setState(() {});}, icon: Icon(Icons.clear)):Container()
              ],
            ),
          ):Text("Market Place",style: TextStyle(color: Colors.green),),
          actions: !isSearch?[
            !loading?IconButton(onPressed: (){
              setState(() {
                isSearch=true;
              });
              print("Search");
            }, icon: Icon(Icons.search)):Container(),
            PopupMenuButton(
              itemBuilder: (context) {
              return List.generate(2, (index) {
                var options=["Add","Your Items"];
                return PopupMenuItem(
                    value: index,
                    child: Text(options[index]),
                  );
                });
              },
              onSelected:(index)async{
                switch(index){
                  case 0:{
                    await Navigator.pushNamed(context, "/addNewCrop",);
                    setState(() {
                      loading=true;
                      result=[];
                    });
                    init();
                    break;
                  }
                  case 1:{
                    await Navigator.pushNamed(context, "/userItems",);
                    setState(() {
                      loading=true;
                      result=[];
                    });
                    init();
                    break;
                  }
                }
              }
            )
          ]:[Container()],
        ),
        body: loading?Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50,width: 50,child: CircularProgressIndicator(strokeWidth: 5,valueColor: AlwaysStoppedAnimation(Colors.green),),),
              SizedBox(height: 10,),
              Text(txt)
            ],
          ),
        ):isSearch?Container():
            GridView.builder(
              itemCount: result.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 8.0 / 15.0,
                crossAxisCount: 2,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                    padding: EdgeInsets.all(5),
                    child: Card(
                      elevation: 10,
                        semanticContainer: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                                child: GestureDetector(
                                  onTap: (){
                                    showPic(context, result[index]["pic"].replaceAll("http://10.0.2.2:3000",url));
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                          image: NetworkImage(result[index]["pic"].replaceAll("http://10.0.2.2:3000",url)),
                                          fit: BoxFit.cover),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(padding: EdgeInsets.all(10),primary: Colors.white,shape: CircleBorder(),),
                                          child: Icon(Icons.call,color: Colors.green,size: 25,),
                                          onPressed: ()async{
                                            await canLaunch("tel:${result[index]["phone"]}") ? await launch("tel:${result[index]["phone"]}") : throw 'Could not launch phone app';
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                            Padding(padding: EdgeInsets.only(left: 10,top: 3,bottom: 10,right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(result[index]["itemName"],style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                SizedBox(height: 5,),
                                Text("Rs.${result[index]["price"]}/Kg",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                                SizedBox(height: 10,),
                                Text(result[index]['username'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                Text(result[index]['place'],style: TextStyle(fontSize: 15),),
                                Text(result[index]["district"],style: TextStyle(fontSize: 15),)
                              ],
                            ),)
                          ],
                        )));
              },
            )
      ),
    );
  }

}


// ListView.builder(
// padding: EdgeInsets.all(10),
// itemCount: result.length,
// itemBuilder: (context,index) {
// return GestureDetector(
// onTap: (){showPic(context, result[index]["pic"]);},
// child: Container(
// margin: EdgeInsets.only(bottom: 10),
// decoration: BoxDecoration(
// borderRadius: BorderRadius.circular(10),
// image: DecorationImage(
// image: NetworkImage(
// result[index]["pic"]),
// fit: BoxFit.cover,
// ),
// ),
// height: 220,
// padding: EdgeInsets.zero,
// child: Stack(
// children: [
// Positioned(
// child: Container(
// padding: EdgeInsets.only(left: 10),
// width: MediaQuery.of(context).size.width-20,
// height: 30.0,
// decoration: new BoxDecoration(
// color: Colors.grey.shade200.withOpacity(0.5)
// ),
// child: Align(
// alignment: Alignment.centerLeft,
// child: Text(
// result[index]["username"],
// style: TextStyle(fontWeight: FontWeight.bold),
// ),
// ),
// ),
// bottom: 90,
// ),
// Positioned(
// bottom: 0,
// width: MediaQuery.of(context).size.width-20,
// child: Container(
// decoration: BoxDecoration(
// boxShadow: [BoxShadow(
// color: Colors.grey,
// blurRadius: 5.0,
// ),],
// borderRadius: BorderRadius.only(bottomRight: Radius.circular(10),bottomLeft: Radius.circular(10)),
// color: Colors.white,
// ),
// padding: EdgeInsets.all(10),
// height: 90,
// child: Row(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
// children: [
// Expanded(
// child: Column(
// children: [
// Text(result[index]["itemName"],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
// SizedBox(height: 3,),
// Text("Rs.${result[index]["price"]}/Kg",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
// SizedBox(height: 3,),
// Text("${result[index]["place"]} ${result[index]["district"]}",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey,fontSize: 16),overflow: TextOverflow.ellipsis,),
// ],
// crossAxisAlignment: CrossAxisAlignment.start,
// )
// ),
// ClipOval(
// child: Material(
// color: Colors.green, // Button color
// child: InkWell(
// splashColor: Colors.green[400], // Splash color
// onTap: () async{
// await canLaunch("tel:${result[index]["phone"]}") ? await launch("tel:${result[index]["phone"]}") : throw 'Could not launch phone app';
// },
// child: SizedBox(width: 56, height: 56, child: Icon(Icons.phone,color: Colors.white,)),
// ),
// ),
// )
// ],
// ),
// )
// )
// ],
// ),
// ),
// );
// }
// )