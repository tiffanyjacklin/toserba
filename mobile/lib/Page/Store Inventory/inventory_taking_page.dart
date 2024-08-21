import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_all/ColorPallete.dart';

class DataStock extends DataTableSource{
  final List<Map<String, dynamic>> _data = List.generate(
    20, 
    (index) => {
      "No" : index+1,
      "Product Name" : 'Test',
      "Batch" : 'coba',
      "Expiry Date" : '01/01/2024',
      "Expected Stock" : 20,
      "Unit Type" : 'Unit',
                  //       DataColumn(label: Text('Expected Stock')),
                  // DataColumn(label: Text('Actual Stock')),
                  // DataColumn(label: Text('Unit Type')),
                  // DataColumn(label: Text('Information')),
    });

  @override
  DataRow? getRow(int index) {
    TextEditingController controller = TextEditingController();
    return DataRow(cells: [
      DataCell(Text(_data[index]['No'].toString())),
      DataCell(Text(_data[index]['Product Name'].toString())),
      DataCell(Text(_data[index]['Batch'].toString())),
      DataCell(Text(_data[index]['Expiry Date'].toString())),
      DataCell(Text(_data[index]['Expected Stock'].toString())),
      DataCell(TextFormField(
        controller: controller,
        onChanged: (value){
          print(value);
        },
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
      )),
      DataCell(Text(_data[index]['No'].toString())),
      DataCell(Text(_data[index]['No'].toString())),
      DataCell(Text(_data[index]['No'].toString())),
    ]);
  }
  
  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;
  
  @override
  // TODO: implement rowCount
  int get rowCount =>  _data.length;
  
  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;

}


class InventoryTakingPage extends StatelessWidget {
  const InventoryTakingPage({super.key});

  @override
  Widget build(BuildContext context) {  
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.grey),
        ),
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only( left: 8.0, right: 8.0, top: 16.0, bottom: 8.0),
          child: Column(
            children: [
              Text('Inventory Taking', style : TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: ColorPalleteLogin.PrimaryColor)),
              SizedBox(height: 10,),
              Container(
                width: MediaQuery.of(context).size.width * 0.70,
                child: CupertinoSearchTextField(       
                  // trailing: Icon(Icons.abc),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                child: PaginatedDataTable(
                  rowsPerPage: 5,
                  columnSpacing: 20,
                  dataRowMinHeight: 20,
                  dataRowMaxHeight: 40,
                  columns: [
                    DataColumn(label: Text('No')),
                    DataColumn(label: Text('Product Name')),
                    DataColumn(label: Text('Batch')),
                    DataColumn(label: Text('Expiry Date')),
                    DataColumn(label: Text('Expected Stock')),
                    DataColumn(label: Text('Actual Stock')),
                    DataColumn(label: Text('Unit Type')),
                    DataColumn(label: Text('Fill')),
                    DataColumn(label: Text('Detail')),
                  ], 
                  source: DataStock()),
              ),

              SizedBox(height: 20,),
              // 
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ButtonTheme(
                    child: ElevatedButton( 
                      onPressed: (){},
                      child: Text('Discard'),
                    ),
                  ),
                  SizedBox(width: 20,),
                  ButtonTheme(
                    child: ElevatedButton( 
                      onPressed: (){},
                      child: Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      );
  }
}