import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { FORM_CARET_COLOR, FORM_PLACEHOLDER_COLOR, FORM_TEXT_COLOR } from '../common/InputStyles';
import { UserSession } from '../common/UserSession';

    @Entry
    @Component
    struct LoginPage {
    @State phone: string = '';
    @State password: string = '';
    @State isPasswordVisible: boolean = false;
    @State isSubmitting: boolean = false;

    aboutToAppear(): void {
        UserSession.init(getContext(this) as Context);
    }

    private async handleLogin(): Promise<void> {
        if (this.isSubmitting) {
        return;
        }
        const phone = this.phone.trim();
        if (phone.length === 0 || this.password.length === 0) {
        AppUtil.toast('请输入手机号和密码');
        return;
        }
        if (!/^1\d{10}$/.test(phone)) {
        AppUtil.toast('请输入正确的11位手机号');
        return;
        }
        if (this.password.length < 6) {
        AppUtil.toast('密码长度不能少于6位');
        return;
        }

        this.isSubmitting = true;
        const res = await HotelApi.login(phone, this.password);
        this.isSubmitting = false;

        if (res.code !== 200 || !res.data) {
        AppUtil.toast(res.message || '登录失败');
        return;
        }

        await UserSession.saveUser(res.data);
        AppUtil.toast(`欢迎回来，${res.data.username}`);
        AppUtil.routeAfterLogin(res.data);
    }

    @Builder
    InputField(label: string, placeholder: string, isPassword: boolean) {
        Column({ space: 8 }) {
        Text(label)
            .fontSize(14)
            .fontColor('#475569')
            .fontWeight(FontWeight.Medium)
            .width('100%')

        if (isPassword) {
            Row() {
            TextInput({ text: this.password, placeholder: placeholder })
                .layoutWeight(1)
                .height(48)
                .fontSize(15)
                .backgroundColor(Color.Transparent)
                .type(this.isPasswordVisible ? InputType.Normal : InputType.Password)
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                .onChange((value: string) => {
                this.password = value;
                })

            Text(this.isPasswordVisible ? '隐藏' : '显示')
                .fontSize(13)
                .fontColor('#2563EB')
                .margin({ right: 4 })
                .onClick(() => {
                this.isPasswordVisible = !this.isPasswordVisible;
                })
            }
            .width('100%')
            .padding({ left: 14, right: 14 })
            .backgroundColor('#F8FAFC')
            .borderRadius(12)
            .border({ width: 1, color: '#E2E8F0' })
        } else {
            TextInput({ text: this.phone, placeholder: placeholder })
            .width('100%')
            .height(48)
            .fontSize(15)
            .backgroundColor('#F8FAFC')
            .borderRadius(12)
            .border({ width: 1, color: '#E2E8F0' })
            .padding({ left: 14, right: 14 })
            .type(InputType.PhoneNumber)
            .maxLength(11)
            .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
            .onChange((value: string) => {
                this.phone = value;
            })
        }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
    }

    build() {
        Column() {
        Column() {
            Column({ space: 14 }) {
            Row() {
                Column() {
                Text('🏨')
                    .fontSize(28)
                }
                .width(64)
                .height(64)
                .justifyContent(FlexAlign.Center)
                .backgroundColor('rgba(255,255,255,0.22)')
                .borderRadius(20)
                .border({ width: 1, color: 'rgba(255,255,255,0.35)' })

                Column({ space: 6 }) {
                Text('酒店推荐预订系统')
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.White)

                Text('发现合适酒店，轻松完成预订')
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.88)')
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 16 })
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
            }
            .width('100%')
            .padding({ left: 24, right: 24, top: 56, bottom: 36 })
        }
        .width('100%')
        .linearGradient({
            angle: 120,
            colors: [['#3B82F6', 0.0], ['#2563EB', 0.55], ['#1D4ED8', 1.0]]
        })

        Scroll() {
            Column() {
            Column({ space: 20 }) {
                Column({ space: 8 }) {
                Text('欢迎回来')
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#0F172A')
                    .width('100%')
                    .textAlign(TextAlign.Center)

                Text('登录以继续浏览酒店、管理订单与收藏')
                    .fontSize(13)
                    .fontColor('#64748B')
                    .width('100%')
                    .textAlign(TextAlign.Center)
                }
                .width('100%')

                this.InputField('手机号', '请输入手机号', false)
                this.InputField('密码', '请输入密码', true)

                Button(this.isSubmitting ? '登录中...' : '登录')
                .width('100%')
                .height(50)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.White)
                .borderRadius(12)
                .enabled(!this.isSubmitting)
                .linearGradient({
                    angle: 120,
                    colors: [['#3B82F6', 0.0], ['#2563EB', 1.0]]
                })
                .shadow({
                    radius: 16,
                    color: 'rgba(37, 99, 235, 0.35)',
                    offsetY: 6
                })
                .margin({ top: 8 })
                .onClick(() => {
                    this.handleLogin();
                })

                Row() {
                Text('注册')
                    .fontSize(14)
                    .fontColor('#2563EB')
                    .fontWeight(FontWeight.Medium)
                    .onClick(() => {
                    router.pushUrl({ url: 'pages/RegisterPage' });
                    })

                Text('|')
                    .fontSize(14)
                    .fontColor('#CBD5E1')
                    .margin({ left: 16, right: 16 })

                Text('忘记密码？')
                    .fontSize(14)
                    .fontColor('#2563EB')
                    .fontWeight(FontWeight.Medium)
                    .onClick(() => {
                    router.pushUrl({ url: 'pages/ChangePasswordPage' });
                    })
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .margin({ top: 4 })

                Text('管理员登录 →')
                    .fontSize(14)
                    .fontColor('#475569')
                    .width('100%')
                    .textAlign(TextAlign.Center)
                    .margin({ top: 16 })
                    .onClick(() => {
                    router.pushUrl({ url: 'pages/AdminLoginPage' });
                    })
            }
            .width('100%')
            .padding(28)
            .backgroundColor(Color.White)
            .borderRadius(20)
            .shadow({
                radius: 24,
                color: 'rgba(15, 23, 42, 0.08)',
                offsetY: 8
            })
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 24, bottom: 32 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F4F6FB')
    }
    }
