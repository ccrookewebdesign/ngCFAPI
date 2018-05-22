import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { LayoutModule } from '@angular/cdk/layout';
import { HttpClientModule } from '@angular/common/http';
import { RouterModule } from '@angular/router';

import { MaterialModule } from './material.module';

import { UserService } from './services/user.service';
import { AuthGuard } from './services/auth.guard';

import { AppComponent } from './app.component';
import { LoginComponent } from './login/login.component';
import { MainNavComponent } from './main-nav/main-nav.component';
import { HomeComponent } from './home/home.component';
import { ProfileComponent } from './profile/profile.component';
import { AutofocusDirective } from './services/autofocus.directive';

@NgModule({
  declarations: [
    AppComponent,
    MainNavComponent,
    LoginComponent,
    HomeComponent,
    ProfileComponent,
    AutofocusDirective
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    FormsModule,
    ReactiveFormsModule,
    LayoutModule,
    HttpClientModule,
    MaterialModule,
    RouterModule.forRoot([
      { path: '', component: HomeComponent, canActivate: [AuthGuard] },
      { path: 'login', component: LoginComponent },
      {
        path: 'profile/:userid',
        component: ProfileComponent,
        canActivate: [AuthGuard]
      },
      { path: 'profile', component: ProfileComponent },
      { path: '**', component: HomeComponent, canActivate: [AuthGuard] }
    ])
  ],
  providers: [UserService, AuthGuard],
  bootstrap: [AppComponent]
})
export class AppModule {}
