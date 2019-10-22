class DiscoverModel {
  final String cast;
  final String dateGte;
  final String dateLte;
  final String rateGte;
  final String rateLte;
  final String adult;
  final String genres;
  final String type;
  final String cert;
  final String certCountry;

  DiscoverModel(
      {this.cast,
      this.dateGte,
      this.dateLte,
      this.rateGte,
      this.rateLte,
      this.adult,
      this.genres,
      this.type,
      this.cert,
      this.certCountry = 'US'});
}
