using System.Text;
using System.Text.Json;
using FitDivas.Application.DTOs.AI;
using FitDivas.Application.Interfaces.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace FitDivas.Infrastructure.Services;

public class AiService(IConfiguration configuration, ILogger<AiService> logger) : IAiService
{
    private static readonly HttpClient _http = new();

    public async Task<AiChatResponseDto> ChatAsync(AiChatRequestDto dto)
    {
        var apiKey = configuration["Anthropic:ApiKey"];
        if (string.IsNullOrEmpty(apiKey))
        {
            return new AiChatResponseDto
            {
                Resposta = "A IA ainda não foi configurada. Adicione a chave 'Anthropic:ApiKey' no appsettings para ativar o assistente."
            };
        }

        try
        {
            return await ChatWithClaudeAsync(dto, apiKey);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Erro ao consultar Claude API");
            return new AiChatResponseDto
            {
                Resposta = "Não consegui responder agora. Tente novamente em alguns instantes."
            };
        }
    }

    private static async Task<AiChatResponseDto> ChatWithClaudeAsync(AiChatRequestDto dto, string apiKey)
    {
        var systemPrompt = BuildSystemPrompt(dto.Contexto);

        // Monta histórico + nova pergunta como array de objetos anônimos
        var messages = dto.Historico
            .Select(m => (object)new { role = m.Role, content = m.Content })
            .Append((object)new { role = "user", content = dto.Pergunta })
            .ToArray();

        var body = new
        {
            model = "claude-haiku-4-5-20251001",
            max_tokens = 1024,
            system = systemPrompt,
            messages
        };

        var request = new HttpRequestMessage(HttpMethod.Post, "https://api.anthropic.com/v1/messages")
        {
            Content = new StringContent(JsonSerializer.Serialize(body), Encoding.UTF8, "application/json")
        };
        request.Headers.Add("x-api-key", apiKey);
        request.Headers.Add("anthropic-version", "2023-06-01");

        var response = await _http.SendAsync(request);
        response.EnsureSuccessStatusCode();

        var json = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        var resposta = json.RootElement
            .GetProperty("content")[0]
            .GetProperty("text")
            .GetString() ?? "Sem resposta.";

        return new AiChatResponseDto { Resposta = resposta };
    }

    private static string BuildSystemPrompt(AiContextoDto? ctx)
    {
        var sb = new StringBuilder();
        sb.AppendLine("Você é a Diva, assistente de saúde e fitness do app FitDivas. Fale em português brasileiro, seja simpática e motivadora.");
        sb.AppendLine();

        if (ctx != null)
        {
            sb.AppendLine("## Dados da usuária");
            if (ctx.Nome != null) sb.AppendLine($"- Nome: {ctx.Nome}");
            if (ctx.Genero != null) sb.AppendLine($"- Gênero: {ctx.Genero}");
            if (ctx.Idade != null) sb.AppendLine($"- Idade: {ctx.Idade} anos");
            if (ctx.AlturaCm != null) sb.AppendLine($"- Altura: {ctx.AlturaCm} cm");

            if (ctx.Objetivo != null)
            {
                var objLabel = ctx.Objetivo == "perda" ? "perda de peso" : "ganho de peso";
                sb.AppendLine($"- Objetivo: {objLabel}");
            }

            if (ctx.PesoAtual != null) sb.AppendLine($"- Peso atual: {ctx.PesoAtual:F1} kg");
            if (ctx.PesoMeta != null) sb.AppendLine($"- Meta de peso: {ctx.PesoMeta:F1} kg");

            if (ctx.StatusProgresso != null)
            {
                var statusLabel = ctx.StatusProgresso switch
                {
                    "adiantado" => "adiantada em relação à previsão",
                    "atrasado" => "abaixo do esperado pela previsão",
                    "no_prazo" => "dentro do prazo previsto",
                    _ => ctx.StatusProgresso
                };
                sb.AppendLine($"- Status atual: {statusLabel}");
            }

            if (ctx.PrevisaoMeta != null) sb.AppendLine($"- Previsão de atingir a meta: {ctx.PrevisaoMeta}");
            sb.AppendLine();
        }

        sb.AppendLine("## Como agir");
        sb.AppendLine("- Personalize suas respostas com base nos dados da usuária quando relevante.");
        sb.AppendLine("- Responda dúvidas sobre treino, nutrição, hidratação, sono, bem-estar e progresso físico.");
        sb.AppendLine("- Interprete o progresso da usuária e motive-a com base no status atual.");
        sb.AppendLine("- Seja concisa: máximo 3 parágrafos curtos por resposta.");
        sb.AppendLine("- Use no máximo 1-2 emojis por resposta.");
        sb.AppendLine("- Para questões médicas sérias, oriente a consultar um profissional de saúde.");
        sb.AppendLine("- Não prescreva medicamentos ou suplementos sem orientação médica.");

        return sb.ToString();
    }
}
