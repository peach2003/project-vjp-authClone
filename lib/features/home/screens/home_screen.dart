import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../widgets/company_list.dart';
import '../widgets/expert_carousel.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(LoadHomeData()),
      child: _HomeContent(),
    );
  }
}

class _HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(),
          body: _buildBody(context, state),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Color.fromARGB(255, 251, 215, 64),
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 120,
            height: 60,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    if (state is HomeLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (state is HomeError) {
      return Center(child: Text(state.message));
    }

    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildBanner(),
          SizedBox(height: 20),
          _buildSearchButton(context),
          SizedBox(height: 20),
          _buildFeaturedCompaniesSection(),
          SizedBox(height: 10),
          _buildExpertsSection(),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Image.network(
      'https://vjp-connect.com/_next/static/media/vjp-connect-banner-sm.eed45626.webp',
      width: double.infinity,
      fit: BoxFit.cover,
      height: 200,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 200,
          color: Colors.grey[300],
          child: Center(child: Text("Không tìm thấy ảnh banner")),
        );
      },
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: () {
        context.read<HomeBloc>().add(SearchCompanies(""));
      },
      child: Text(
        "Tìm doanh nghiệp",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFeaturedCompaniesSection() {
    return Column(
      children: [
        Text(
          "NHỮNG CÔNG TY NỔI BẬT",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10),
        Padding(padding: const EdgeInsets.all(16.0), child: CompanyList()),
      ],
    );
  }

  Widget _buildExpertsSection() {
    return Column(
      children: [
        Text(
          "CÁC CHUYÊN GIA HỖ TRỢ",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10),
        _buildExpertTitle(),
        SizedBox(height: 10),
        ExpertCarousel(),
      ],
    );
  }

  Widget _buildExpertTitle() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.blue, thickness: 1, indent: 70)),
        SizedBox(width: 10),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "CHUYÊN GIA ĐẠI DIỆN",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Divider(color: Colors.blue, thickness: 1, endIndent: 70),
        ),
      ],
    );
  }
}
