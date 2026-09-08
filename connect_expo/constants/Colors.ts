/** Brand colors from Flutter `AppColors`. */
const tintColorLight = '#EF274D';
const tintColorDark = '#EF274D';

export const Brand = {
  primary: '#EF274D',
  primaryTop: '#E92A4F',
  primaryBottom: '#EC5270',
  videoBackground: '#FD2E38',
  scaffoldDark: '#141414',
  bgGrey: '#303030',
  txtGrey: '#8C8C8C',
  textPrimary: '#1E232C',
  lightText: '#181D27',
  textLight: '#86878B',
  border: '#D8D8D8',
  borderLight: '#E3E3E4',
  lightBorder: '#BCBCBC',
  iconColor: '#787878',
  primaryIconColor: '#242424',
  green: '#50E49D',
  purple: '#5754FC',
  white: '#FFFFFF',
  black: '#000000',
} as const;

export default {
  light: {
    text: Brand.textPrimary,
    background: Brand.white,
    tint: tintColorLight,
    tabIconDefault: Brand.txtGrey,
    tabIconSelected: tintColorLight,
  },
  dark: {
    text: Brand.white,
    background: Brand.scaffoldDark,
    tint: tintColorDark,
    tabIconDefault: Brand.txtGrey,
    tabIconSelected: tintColorDark,
  },
};
