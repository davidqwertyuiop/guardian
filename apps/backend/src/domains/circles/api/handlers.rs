use axum::{extract::{State, Path}, Json};
use uuid::Uuid;
use crate::routes::AppState;
use crate::shared::{errors::AppError, middleware::auth::AuthUser};
use crate::domains::circles::{
    application::{
        create_circle::CreateCircleUseCase,
        join_by_code::JoinByCodeUseCase,
        join_by_link::JoinByLinkUseCase,
    },
    api::dto::*,
};


// ── POST /api/v1/circles ────────────────────────────────────────────────────

pub async fn create_circle(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Json(body): Json<CreateCircleRequest>,
) -> Result<Json<CreateCircleResponse>, AppError> {
    let owner_id: Uuid = claims.sub.parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    let uc = CreateCircleUseCase {
        circle_repo: state.circle_repo.clone(),
        invite_repo: state.invite_repo.clone(),
    };
    let output = uc.execute(owner_id, &body.name).await?;

    Ok(Json(CreateCircleResponse {
        circle: CircleResponse {
            id: output.circle.id.to_string(),
            name: output.circle.name,
            owner_id: output.circle.owner_id.to_string(),
            created_at: output.circle.created_at,
        },
        invite: InviteResponse {
            code: output.invite.code.clone(),
            invite_link: format!("{}/{}", state.config.invite_base_url, output.invite.token),
            code_expires_at: output.invite.code_expires_at,
            link_expires_at: output.invite.link_expires_at,
        },
    }))
}

// ── GET /api/v1/circles ─────────────────────────────────────────────────────

pub async fn list_circles(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
) -> Result<Json<Vec<CircleResponse>>, AppError> {
    let user_id: Uuid = claims.sub.parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    let circles = state.circle_repo.list_for_user(user_id).await?;
    let resp = circles.into_iter().map(|c| CircleResponse {
        id: c.id.to_string(),
        name: c.name,
        owner_id: c.owner_id.to_string(),
        created_at: c.created_at,
    }).collect();

    Ok(Json(resp))
}

// ── GET /api/v1/circles/:id/members ────────────────────────────────────────

pub async fn get_members(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Path(circle_id): Path<Uuid>,
) -> Result<Json<Vec<MemberResponse>>, AppError> {
    let user_id: Uuid = claims.sub.parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    // Only members can see the list
    if !state.circle_repo.is_member(circle_id, user_id).await? {
        return Err(AppError::Unauthorized("You are not a member of this circle.".into()));
    }

    let members = state.circle_repo.get_members(circle_id).await?;
    let resp = members.into_iter().map(|m| MemberResponse {
        user_id: m.user_id.to_string(),
        name: m.name,
        avatar_url: m.avatar_url,
        phone: m.phone,
        role: m.role,
        joined_at: m.joined_at,
    }).collect();

    Ok(Json(resp))
}

// ── POST /api/v1/circles/join/code ─────────────────────────────────────────

pub async fn join_by_code(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Json(body): Json<JoinByCodeRequest>,
) -> Result<Json<JoinCircleResponse>, AppError> {
    let user_id: Uuid = claims.sub.parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    let uc = JoinByCodeUseCase {
        circle_repo: state.circle_repo.clone(),
        invite_repo: state.invite_repo.clone(),
    };
    let circle_id = uc.execute(user_id, &body.code).await?;

    Ok(Json(JoinCircleResponse {
        circle_id: circle_id.to_string(),
        message: "Successfully joined the circle".into(),
    }))
}

// ── POST /api/v1/circles/join/link ─────────────────────────────────────────

pub async fn join_by_link(
    State(state): State<AppState>,
    AuthUser(claims): AuthUser,
    Json(body): Json<JoinByLinkRequest>,
) -> Result<Json<JoinCircleResponse>, AppError> {
    let user_id: Uuid = claims.sub.parse()
        .map_err(|_| AppError::InvalidInput("Invalid user id in token".into()))?;

    let uc = JoinByLinkUseCase {
        circle_repo: state.circle_repo.clone(),
        invite_repo: state.invite_repo.clone(),
    };
    let circle_id = uc.execute(user_id, &body.token).await?;

    Ok(Json(JoinCircleResponse {
        circle_id: circle_id.to_string(),
        message: "Successfully joined the circle via invite link".into(),
    }))
}

// ── GET /invite/{token} ─────────────────────────────────────────────────────

pub async fn invite_landing_page(
    Path(token): Path<String>,
) -> axum::response::Html<String> {
    let app_store_link = "https://apps.apple.com/app/guardian"; 
    let play_store_link = "https://play.google.com/store/apps/details?id=com.sijibomi.guardian"; 

    let html = format!(r#"<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Join Circle | Guardian</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;800&display=swap" rel="stylesheet">
    <style>
        body {{
            margin: 0;
            padding: 0;
            background-color: #0E0E12;
            color: #FFFFFF;
            font-family: 'Outfit', sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            text-align: center;
            box-sizing: border-box;
        }}
        .container {{
            max-width: 480px;
            width: 90%;
            padding: 40px 24px;
            background: linear-gradient(135deg, #161622 0%, #111119 100%);
            border: 1px solid rgba(255, 255, 255, 0.05);
            border-radius: 32px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.5);
            display: flex;
            flex-direction: column;
            align-items: center;
        }}
        .logo {{
            width: 80px;
            height: 80px;
            background-color: #8069FF;
            border-radius: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 30px;
            box-shadow: 0 10px 25px rgba(128, 105, 255, 0.3);
        }}
        .logo-icon {{
            font-size: 40px;
        }}
        h1 {{
            font-size: 28px;
            font-weight: 800;
            margin: 0 0 12px 0;
            background: linear-gradient(120deg, #FFFFFF 0%, #E5DEFF 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }}
        p {{
            font-size: 16px;
            color: #A0A0B0;
            line-height: 1.6;
            margin: 0 0 35px 0;
        }}
        .btn {{
            width: 100%;
            padding: 16px;
            font-size: 16px;
            font-weight: 600;
            border-radius: 16px;
            border: none;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            box-sizing: border-box;
            transition: all 0.2s ease;
            margin-bottom: 12px;
        }}
        .btn-primary {{
            background-color: #8069FF;
            color: #FFFFFF;
            box-shadow: 0 6px 20px rgba(128, 105, 255, 0.2);
        }}
        .btn-primary:hover {{
            background-color: #6C55EB;
            transform: translateY(-2px);
        }}
        .btn-secondary {{
            background-color: rgba(255, 255, 255, 0.05);
            color: #FFFFFF;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }}
        .btn-secondary:hover {{
            background-color: rgba(255, 255, 255, 0.1);
            transform: translateY(-2px);
        }}
    </style>
    <script>
        window.onload = function() {{
            var token = "{token}";
            var appUrl = "guardian://invite/" + token;
            var appStoreLink = "{app_store_link}";
            var playStoreLink = "{play_store_link}";
            
            var userAgent = navigator.userAgent || navigator.vendor || window.opera;
            var isIOS = /iPad|iPhone|iPod/.test(userAgent) && !window.MSStream;
            var isAndroid = /android/i.test(userAgent);
            
            if (isIOS || isAndroid) {{
                window.location = appUrl;
                
                setTimeout(function() {{
                    if (document.hasFocus()) {{
                        window.location = isIOS ? appStoreLink : playStoreLink;
                    }}
                }}, 1500);
            }}
        }}
    </script>
</head>
<body>
    <div class="container">
        <div class="logo">
            <span class="logo-icon">📍</span>
        </div>
        <h1>You've been invited!</h1>
        <p>Join a secure circle on Guardian to stay connected and keep each other safe.</p>
        
        <a href="guardian://invite/{token}" class="btn btn-primary">Open Guardian App</a>
        
        <script>
            var userAgent = navigator.userAgent || navigator.vendor || window.opera;
            var isIOS = /iPad|iPhone|iPod/.test(userAgent) && !window.MSStream;
            var isAndroid = /android/i.test(userAgent);
            var storeLink = isIOS ? "{app_store_link}" : "{play_store_link}";
            var storeText = isIOS ? "Download on App Store" : "Get it on Google Play";
            
            if (isIOS || isAndroid) {{
                document.write('<a href="' + storeLink + '" class="btn btn-secondary">' + storeText + '</a>');
            }} else {{
                document.write('<a href="{play_store_link}" class="btn btn-secondary" style="margin-bottom: 8px;">Google Play</a>');
                document.write('<a href="{app_store_link}" class="btn btn-secondary">Apple App Store</a>');
            }}
        </script>
    </div>
</body>
</html>"#, token = token, app_store_link = app_store_link, play_store_link = play_store_link);

    axum::response::Html(html)
}
