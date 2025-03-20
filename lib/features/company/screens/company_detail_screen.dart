import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/company_model.dart';
import '../bloc/company_detail_bloc.dart';
import '../bloc/company_detail_event.dart';
import '../bloc/company_detail_state.dart';

class CompanyDetailScreen extends StatelessWidget {
  final Company company;

  const CompanyDetailScreen({Key? key, required this.company})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CompanyDetailBloc()..add(LoadCompanyDetail(company)),
      child: _CompanyDetailContent(),
    );
  }
}

class _CompanyDetailContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyDetailBloc, CompanyDetailState>(
      builder: (context, state) {
        if (state is CompanyDetailLoaded) {
          return Scaffold(
            appBar: _buildAppBar(context),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeaderSection(context, state),
                  SizedBox(height: 40),
                  _buildIntroductionSection(context, state),
                ],
              ),
            ),
          );
        }
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.1),
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, CompanyDetailLoaded state) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage("https://vjp-connect.com/images/background2.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                state.company.imageUrl,
                fit: BoxFit.cover,
                height: 150,
                errorBuilder:
                    (context, error, stackTrace) =>
                        Icon(Icons.business, size: 80, color: Colors.grey),
              ),
            ),
            SizedBox(height: 20),
            Text(
              state.company.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            _buildDetailRow(
              "Năm Thành Lập: ",
              state.company.established.toString(),
            ),
            _buildDetailRow("Nhân Viên: ", state.company.employees.toString()),
            SizedBox(height: 10),
            _buildDetailRow("Vốn Doanh Nghiệp: ", state.company.capital),
            SizedBox(height: 10),
            Text(state.company.address, style: TextStyle(fontSize: 17)),
            SizedBox(height: 10),
            _buildDetailRow("Nhu Cầu: ", state.company.needs),
            SizedBox(height: 10),
            _buildLogoSection(state.company.country),
            SizedBox(height: 10),
            _buildGroupSection(state.company.group),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection(String country) {
    if (country == "Vietnam") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildLogo("https://vjp-connect.com/images/logo1.png"),
          SizedBox(width: 8),
          _buildLogo("https://vjp-connect.com/images/logo2.png"),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildLogo("https://vjp-connect.com/images/logo1.png"),
          SizedBox(width: 8),
          _buildLogo("https://vjp-connect.com/images/logo4.png"),
        ],
      );
    }
  }

  Widget _buildLogo(String url) {
    return Image.network(
      url,
      width: 60,
      height: 50,
      errorBuilder:
          (context, error, stackTrace) =>
              Icon(Icons.error, size: 24, color: Colors.grey),
    );
  }

  Widget _buildGroupSection(String group) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.network(
          "https://vjp-connect.com/_next/static/media/Icon_Group.e6df7480.svg",
          width: 50,
          height: 50,
          color: const Color.fromARGB(255, 227, 212, 1),
          colorBlendMode: BlendMode.srcIn,
          placeholderBuilder:
              (context) => Icon(Icons.error, size: 24, color: Colors.grey),
        ),
        SizedBox(width: 8),
        Text(
          group,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildIntroductionSection(
    BuildContext context,
    CompanyDetailLoaded state,
  ) {
    return Column(
      children: [
        Text(
          "LỜI GIỚI THIỆU",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10),
        _buildIntroductionHeader(),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                state.isExpanded
                    ? state.company.introduction
                    : state.truncatedText,
                style: TextStyle(fontSize: 17, height: 2, color: Colors.black),
              ),
              SizedBox(height: 10),
              if (state.company.introduction.length >
                  state.truncatedText.length)
                _buildExpandButton(context, state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntroductionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Divider(
            color: Colors.blue,
            thickness: 1,
            endIndent: 20,
            indent: 20,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "GIỚI THIỆU SƠ LƯỢC VỀ",
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
            Text("CÔNG TY", style: TextStyle(fontSize: 18, color: Colors.blue)),
          ],
        ),
        Expanded(
          child: Divider(
            color: Colors.blue,
            thickness: 1,
            endIndent: 20,
            indent: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandButton(BuildContext context, CompanyDetailLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(50),
      ),
      child: IconButton(
        onPressed: () {
          context.read<CompanyDetailBloc>().add(
            ToggleIntroduction(!state.isExpanded),
          );
        },
        icon: Icon(
          state.isExpanded
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          color: Colors.blue,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 17,
                height: 1.5,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: Colors.black, fontSize: 17, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
